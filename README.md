# Graph Databases Final Project: Fraud Detection with Neo4j

This project is a small, runnable demo for learning graph databases with Neo4j.
It uses a suspicious transaction / fraud detection scenario because fraud questions
are often relationship-heavy:

> Which accounts look suspicious, and how are they connected?

The project includes:

- Neo4j running with Docker Compose
- CSV test data
- Cypher scripts for loading and querying the graph
- SQL comparison files
- A beginner-friendly tutorial handout
- Small Python helper scripts

## Project Structure

```text
.
├── README.md
├── docker-compose.yml
├── data/
├── cypher/
├── sql-comparison/
├── scripts/
└── tutorial/
```

## Requirements

- Docker Desktop
- Git
- Optional: Python 3.10+ for helper scripts

No local Neo4j installation is required.

## Quick Start

1. Start Neo4j:

   ```bash
   docker compose up -d
   ```

2. Open Neo4j Browser:

   <http://localhost:7474>

3. Log in:

   ```text
   Username: neo4j
   Password: password123
   ```

4. Run the Cypher files in this order:

   ```text
   cypher/01_constraints.cypher
   cypher/02_load_data.cypher
   cypher/03_basic_queries.cypher
   cypher/04_suspicious_patterns.cypher
   cypher/05_shortest_path.cypher
   ```

In Neo4j Browser, paste one query at a time and click Run.

   Optional command-line loading for PowerShell:

   ```powershell
   Get-Content .\cypher\01_constraints.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
   Get-Content .\cypher\02_load_data.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
   ```

   Optional command-line loading for macOS, Linux, or Git Bash:

   ```bash
   cat cypher/01_constraints.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
   cat cypher/02_load_data.cypher | docker exec -i graph-db-final-project-neo4j cypher-shell -u neo4j -p password123
   ```

## Data Model

Main node labels:

- `Person`
- `Account`
- `Transaction`
- `Device`
- `PhoneNumber`
- `Address`
- `Merchant`

Main relationships:

- `(:Person)-[:OWNS]->(:Account)`
- `(:Account)-[:SENT]->(:Transaction)`
- `(:Transaction)-[:TO]->(:Account)`
- `(:Person)-[:USES_DEVICE]->(:Device)`
- `(:Person)-[:HAS_PHONE]->(:PhoneNumber)`
- `(:Person)-[:LIVES_AT]->(:Address)`
- `(:Account)-[:PAID]->(:Merchant)`

## Suspicious Scenarios in the Sample Data

The sample data intentionally includes obvious patterns:

1. Alice and Bob share the same device, phone number, and address.
2. Carol, Dave, and Eve move money in a circle.
3. Frank and Grace share contact details and connect into the same transaction network.

These patterns are meant to be easy to see in Neo4j Browser during a live demo.

## Useful Demo Queries

Show the whole graph:

```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 100;
```

Find people sharing devices:

```cypher
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, d.device_id AS shared_device;
```

Find circular money movement:

```cypher
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
RETURN path;
```

Find shortest path between suspicious accounts:

```cypher
MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;
```

## Resetting the Database

To delete all data and reload from CSV:

```cypher
MATCH (n) DETACH DELETE n;
```

Then rerun:

```text
cypher/01_constraints.cypher
cypher/02_load_data.cypher
```

## Teaching Takeaway

Graph databases are not better for everything. They are better when relationships
are the main thing we need to query
