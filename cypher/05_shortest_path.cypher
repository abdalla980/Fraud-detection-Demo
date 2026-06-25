// Shortest path examples.
// Undirected paths are useful for exploring "how are these connected?"

// 1. Shortest path between two flagged accounts.
MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;

// Expected:
// A700 connects to A300 through transaction T007, so the path is short.

// 2. Shortest path between Alice's account and Eve's flagged account.
MATCH (start:Account {account_id: "A100"}), (end:Account {account_id: "A500"})
MATCH path = shortestPath((start)-[*..10]-(end))
RETURN path;

// 3. Show high-risk people and their nearby accounts.
MATCH (p:Person)
WHERE p.risk_score >= 80
MATCH path = (p)-[*1..4]-(nearby)
WHERE nearby:Account OR nearby:Person
RETURN path
LIMIT 25;

