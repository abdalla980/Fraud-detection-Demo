# Student Handout: Graph Databases with Neo4j

## Goal

In this tutorial, you will build and query a small fraud detection graph.

By the end, you should be able to:

- Explain nodes, relationships, and properties
- Load CSV data into Neo4j
- Write basic Cypher queries
- Find suspicious shared devices, phone numbers, and addresses
- Find transaction chains and shortest paths
- Explain why graph databases are useful for connected data

## Schedule

```text
0:00-0:10  Setup Docker and open Neo4j
0:10-0:25  Explain graph model
0:25-0:40  Load fraud/transaction data
0:40-1:00  Run basic Cypher queries
1:00-1:20  Find shared devices, phones, and addresses
1:20-1:40  Find transaction chains and shortest paths
1:40-1:55  Use GenAI to generate extra fake fraud data or queries
1:55-2:00  Wrap-up and feedback
```

## 1. Start Neo4j

From the project folder, run:

```bash
docker compose up -d
```

Open:

<http://localhost:7474>

Login:

```text
Username: neo4j
Password: password123
```

## 2. Load the Data

Open each file and paste the Cypher into Neo4j Browser in this order:

```text
cypher/01_constraints.cypher
cypher/02_load_data.cypher
```

If your teacher wants you to use PowerShell instead, run:

```powershell
Get-Content .\cypher\01_constraints.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
Get-Content .\cypher\02_load_data.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
```

On macOS, Linux, or Git Bash:

```bash
cat cypher/01_constraints.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
cat cypher/02_load_data.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
```

Check that data loaded:

```cypher
MATCH (n)
RETURN labels(n) AS labels, count(*) AS count
ORDER BY labels;
```

Expected counts:

```text
Account: 9
Address: 6
Device: 7
Merchant: 3
Person: 8
PhoneNumber: 6
Transaction: 12
```

## 3. Basic Graph Query

Show part of the graph:

```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 50;
```

Find Alice's accounts:

```cypher
MATCH (p:Person {name: "Alice Martin"})-[:OWNS]->(a:Account)
RETURN p.name AS person, a.account_id AS account, a.account_type AS type, a.status AS status;
```

Expected result:

```text
Alice Martin owns A100 and A101.
```

## 4. Shared Device Pattern

```cypher
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, d.device_id AS shared_device, d.label AS device_label;
```

Expected result:

```text
Alice Martin and Bob Chen share D001.
```

## 5. Shared Phone Pattern

```cypher
MATCH (p1:Person)-[:HAS_PHONE]->(ph:PhoneNumber)<-[:HAS_PHONE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, ph.phone_number AS shared_phone;
```

Expected results:

```text
Alice Martin and Bob Chen share +1-555-0101.
Frank Diaz and Grace Kim share +1-555-0199.
```

## 6. Circular Transfer Pattern

```cypher
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
WHERE a1.account_id < a2.account_id AND a1.account_id < a3.account_id
RETURN path;
```

Expected result:

```text
A300 -> A400 -> A500 -> A300
```

## 7. Shortest Path

```cypher
MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;
```

Expected result:

```text
A700 is directly connected to A300 through transaction T007.
```

## 8. SQL Comparison

Look at:

```text
sql-comparison/equivalent_queries.sql
```

Compare the circular transfer query in SQL with the Cypher version.

Discussion question:

```text
Which version is easier to read when the question is about relationships?
```

## 9. GenAI Exercise

Use a GenAI assistant to ask for one new suspicious scenario, for example:

```text
Create 3 fake people, 3 accounts, and 5 transactions that show a mule account pattern.
Return the answer as CSV rows compatible with this project.
```

Important:

GenAI is useful for speed, but you still need to check the generated data and
queries carefully.

## Wrap-Up

Graph databases are not better for everything. They are better when relationships
are the main thing we need to query.
