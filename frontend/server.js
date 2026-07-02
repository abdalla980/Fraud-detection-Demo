const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = 8080;

const NEO4J_URL  = 'http://localhost:7474/db/neo4j/tx/commit';
const NEO4J_AUTH = 'Basic ' + Buffer.from('neo4j:password123').toString('base64');

const MIME = {
  '.html': 'text/html',
  '.css':  'text/css',
  '.js':   'application/javascript',
  '.json': 'application/json',
  '.ico':  'image/x-icon',
};

// ── Neo4j query helper ───────────────────────────────────────────
// Runs one Cypher statement over Neo4j's HTTP transactional endpoint
// and returns rows as plain arrays (same shape as the RETURN clause).
async function cypher(statement, parameters = {}) {
  const res = await fetch(NEO4J_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': NEO4J_AUTH },
    body: JSON.stringify({ statements: [{ statement, parameters }] }),
  });
  if (!res.ok) throw new Error(`Neo4j HTTP ${res.status}`);
  const json = await res.json();
  if (json.errors?.length) throw new Error(json.errors[0].message);
  return json.results[0]?.data.map(d => d.row) ?? [];
}

// ── Fraud signal queries ──────────────────────────────────────────
// Signal 1: the two account owners share a device — the strongest synthetic-
// identity signal (people legitimately share a phone or address more often
// than they legitimately share one physical device).
const IDENTITY_QUERY = `
  MATCH (fromAcc:Account {account_id: $from})<-[:OWNS]-(p1:Person)
  MATCH (toAcc:Account {account_id: $to})<-[:OWNS]-(p2:Person)
  MATCH (p1)-[:USES_DEVICE]->(shared:Device)<-[:USES_DEVICE]-(p2)
  WHERE p1 <> p2
  RETURN p1.name AS person1, p2.name AS person2, labels(shared)[0] AS sharedType
  LIMIT 1
`;

// Signal 2: from and to are both members of an existing 3-account circular
// transfer loop (A -> B -> C -> A), regardless of which two sides of the
// loop this new transfer covers.
const CYCLE_QUERY = `
  MATCH (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
        -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
        -[:SENT]->(:Transaction)-[:TO]->(a1)
  WHERE a1.account_id <> a2.account_id AND a2.account_id <> a3.account_id AND a1.account_id <> a3.account_id
  WITH [a1.account_id, a2.account_id, a3.account_id] AS ring
  WHERE $from IN ring AND $to IN ring
  RETURN ring
  LIMIT 1
`;

// Signal 3: one side of the transfer is owned by someone who shares contact
// details with another person whose account routes money into a
// high-risk-owned account (a mule feeding a ring).
const MULE_QUERY = `
  MATCH (acc:Account {account_id: $accountId})<-[:OWNS]-(owner:Person)
  MATCH (owner)-[:HAS_PHONE|LIVES_AT|USES_DEVICE]->(shared)<-[:HAS_PHONE|LIVES_AT|USES_DEVICE]-(other:Person)
  WHERE owner <> other
  MATCH (other)-[:OWNS]->(:Account)-[:SENT]->(:Transaction)-[:TO]->(ringAcc:Account)<-[:OWNS]-(ringPerson:Person)
  WHERE ringPerson.risk_score >= 75 AND ringPerson <> owner AND ringAcc <> acc
  RETURN other.name AS connectedPerson, ringAcc.account_id AS ringAccount
  LIMIT 1
`;

async function checkFraud(from, to) {
  const identity = await cypher(IDENTITY_QUERY, { from, to });
  if (identity.length) {
    const [person1, person2, sharedType] = identity[0];
    return {
      blocked: true,
      patternId: 'takeover',
      subtitle: 'Shared Identity Signal',
      body: `${person1} (owner of ${from}) and ${person2} (owner of ${to}) share the same ${String(sharedType).toLowerCase()} — a strong indicator of synthetic identity fraud.`,
    };
  }

  const cycle = await cypher(CYCLE_QUERY, { from, to });
  if (cycle.length) {
    const ring = cycle[0][0];
    return {
      blocked: true,
      patternId: 'laundering',
      subtitle: 'Circular Transfer Pattern Detected',
      body: `${from} and ${to} are both part of a circular transfer loop (${ring.join(' → ')} → ${ring[0]}). Funds cycling back to their origin account is a classic money-laundering signal.`,
    };
  }

  for (const accountId of [from, to]) {
    const mule = await cypher(MULE_QUERY, { accountId });
    if (mule.length) {
      const [connectedPerson, ringAccount] = mule[0];
      return {
        blocked: true,
        patternId: 'mule',
        subtitle: 'Mule Network Activity',
        body: `${accountId} is linked through shared contact details to ${connectedPerson}, whose account routes funds into ${ringAccount} — a known laundering ring.`,
      };
    }
  }

  return { blocked: false };
}

function handleTransfer(req, res) {
  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', async () => {
    try {
      const { from, to } = JSON.parse(body);
      const result = await checkFraud(from, to);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ ...result, from, to }));
    } catch (err) {
      res.writeHead(503, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Fraud detection service unavailable', detail: err.message }));
    }
  });
}

function handleStatic(req, res) {
  const pathname = new URL(req.url, 'http://localhost').pathname;
  const filePath  = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
  const ext       = path.extname(filePath);

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': MIME[ext] || 'text/plain' });
    res.end(data);
  });
}

http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/api/transfer') {
    handleTransfer(req, res);
    return;
  }
  handleStatic(req, res);
}).listen(PORT, () => {
  console.log(`Fraud Detection running at http://localhost:${PORT}`);
});
