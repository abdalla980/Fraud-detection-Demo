// Basic queries for the first part of the demo.

// 1. Show a small part of the graph.
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 50;

// 2. Show accounts owned by one person.
MATCH (p:Person {name: "Alice Martin"})-[:OWNS]->(a:Account)
RETURN p.name AS person, a.account_id AS account, a.account_type AS type, a.status AS status;

// Expected result:
// Alice Martin owns A100 and A101.

// 3. Show all people and their accounts.
MATCH (p:Person)-[:OWNS]->(a:Account)
RETURN p.name AS person, p.risk_score AS risk_score, collect(a.account_id) AS accounts
ORDER BY p.risk_score DESC;

// 4. Show outgoing transfers from flagged accounts.
MATCH (p:Person)-[:OWNS]->(a:Account {status: "flagged"})-[:SENT]->(t:Transaction)-[:TO]->(target:Account)
RETURN p.name AS sender, a.account_id AS from_account, target.account_id AS to_account,
       t.amount AS amount, t.timestamp AS timestamp
ORDER BY t.timestamp;

