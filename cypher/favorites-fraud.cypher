// Verify — Count every node by label
MATCH (n)
RETURN labels(n), count(*)
ORDER BY labels(n);

// Pattern 1 — List everything
MATCH (p:Person)
RETURN p.name, p.risk_score;

// Pattern 2 — Sort it
MATCH (p:Person)
RETURN p.name, p.risk_score
ORDER BY p.risk_score ASC;

// Pattern 3 — Filter by a condition
MATCH (t:Transaction)
WHERE t.amount > 500
RETURN t.transaction_id, t.amount;

// Pattern 4 — Count everything
MATCH (p:Person)
RETURN count(p);

// Pattern 5 — Look up one specific thing's connections
MATCH (p:Person {name: "Alice Martin"})-[:OWNS]->(a:Account)
RETURN a.account_id;

// Pattern 6 — List every pair
MATCH (p:Person)-[:OWNS]->(a:Account)
RETURN p.name, a.account_id;

// Pattern 7 — Follow a relationship backwards
MATCH (a:Account {account_id: "A300"})<-[:OWNS]-(p:Person)
RETURN p.name;

// Pattern 8 — Count per group (implicit GROUP BY)
MATCH (p:Person)-[:OWNS]->(a:Account)
RETURN p.name, count(a);

// Pattern 9 — Filter on a relationship's own property
MATCH (a:Account)-[paid:PAID]->(m:Merchant)
WHERE paid.amount > 100
RETURN a.account_id, m.name, paid.amount;

// Pattern 10 — Only the top one
MATCH (p:Person)
RETURN p.name, p.risk_score
ORDER BY p.risk_score DESC
LIMIT 1;

// Pattern 11 — Top N
MATCH (p:Person)
RETURN p.name, p.risk_score
ORDER BY p.risk_score DESC
LIMIT 3;

// Pattern 12 — Total per group
MATCH (a:Account)-[:SENT]->(t:Transaction)
RETURN a.account_id, sum(t.amount)
ORDER BY sum(t.amount) DESC;

// Pattern 13 — Total per group, using a relationship's own property
MATCH (a:Account)-[paid:PAID]->(m:Merchant)
RETURN m.name, sum(paid.amount)
ORDER BY sum(paid.amount) DESC;

// Fraud 1 — Shared device (account takeover)
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name, p2.name, d.device_id, d.label;

// Fraud 2 — Shared phone
MATCH (p1:Person)-[:HAS_PHONE]->(ph:PhoneNumber)<-[:HAS_PHONE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name, p2.name, ph.phone_number;

// Fraud 3 — Circular transfer (money laundering)
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
WHERE a1.account_id < a2.account_id AND a1.account_id < a3.account_id
RETURN path;

// Fraud 4 — Shortest path between two accounts
MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;

// CRUD 1 — Create a node
CREATE (p:Person {person_id: "P999", name: "Test Person", risk_score: 50})
RETURN p;

// CRUD 2 — Create a relationship
MATCH (p:Person {person_id: "P999"})
CREATE (a:Account {account_id: "A999", account_type: "checking", status: "active"})
CREATE (p)-[:OWNS]->(a)
RETURN p.name, a.account_id;

// CRUD 3 — Update a property
MATCH (p:Person {person_id: "P999"})
SET p.risk_score = 95
RETURN p.name, p.risk_score;

// CRUD 4 — Delete (cleanup the practice node + its account)
MATCH (p:Person {person_id: "P999"})
OPTIONAL MATCH (p)-[:OWNS]->(a:Account {account_id: "A999"})
DETACH DELETE p, a;
