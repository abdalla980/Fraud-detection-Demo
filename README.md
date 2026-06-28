# Fraud Detection with Neo4j

A self-contained demo for teaching graph databases through a fraud detection scenario.
The core question the dataset is built around:

> Which accounts look suspicious, and how are they connected?

---

## Project Structure

```text
.
├── docker-compose.yml        Neo4j database (Docker)
├── data/                     CSV source files
├── cypher/                   Cypher scripts (load + query)
├── frontend/
│   ├── bank.html             SRH Bank demo — triggers fraud alerts
│   ├── index.html            Graph visualization (Cytoscape.js)
│   ├── server.js             Node.js static file server
│   └── package.json
├── bloom/                    Bloom perspective (requires Neo4j Desktop)
├── sql-comparison/           SQL vs Cypher comparison
├── scripts/                  Python data generator + benchmark
└── tutorial/                 Student handout + troubleshooting guide
```

---

## Requirements

- Docker Desktop
- Node.js 18+
- Git

---

## Setup

### 1. Start Neo4j

```powershell
docker compose up -d
```

### 2. Load the data

```powershell
docker cp .\cypher\01_constraints.cypher graph-db-final-project-neo4j:/tmp/01.cypher
docker cp .\cypher\02_load_data.cypher    graph-db-final-project-neo4j:/tmp/02.cypher
docker exec graph-db-final-project-neo4j bash -c "sed -i 's/^\xEF\xBB\xBF//' /tmp/01.cypher /tmp/02.cypher"
docker exec graph-db-final-project-neo4j cypher-shell -u neo4j -p password123 -f /tmp/01.cypher
docker exec graph-db-final-project-neo4j cypher-shell -u neo4j -p password123 -f /tmp/02.cypher
```

### 3. Start the frontend

```powershell
cd frontend
npm start
```

---

## Demo Flow

Open two browser tabs:

| Tab | URL | Purpose |
|-----|-----|---------|
| Bank portal | http://localhost:8080/bank.html | Show the fraud alert firing |
| Graph view  | http://localhost:8080           | Explain why it was caught   |

**Script:**

1. Open the bank portal as **Carol (A300)**
2. Click **Send Money** — send any amount to `A400 Dave Wilson`
3. After 1.8s the transaction is declined with a fraud alert
4. Click **View Fraud Investigation** — the graph opens with the money laundering ring highlighted
5. Walk through the Cypher query live

The bank portal has three demo accounts selectable from the top bar:

| Account | Fraud scenario triggered |
|---------|--------------------------|
| Carol (A300) | Circular transfer alert when sending to A400 or A500 |
| Alice (A100) | Shared identity alert when sending to A200 (Bob) |
| Frank (A600) | Mule network alert when sending to A700 (Grace) |

---

## Data Model

**Node labels**

| Label | Key property | Color in graph |
|-------|-------------|----------------|
| Person | name, risk_score | Bright red |
| Account | account_id, status | Cobalt blue |
| Transaction | transaction_id, amount | Amber gold |
| Device | device_type, label | Emerald green |
| PhoneNumber | phone_number | Vivid purple |
| Address | street, city | Cyan |
| Merchant | name, category | Orange |

Person node size in the graph scales with `risk_score`.

**Relationships**

```
(:Person)-[:OWNS]->(:Account)
(:Account)-[:SENT]->(:Transaction)
(:Transaction)-[:TO]->(:Account)
(:Person)-[:USES_DEVICE]->(:Device)
(:Person)-[:HAS_PHONE]->(:PhoneNumber)
(:Person)-[:LIVES_AT]->(:Address)
(:Account)-[:PAID]->(:Merchant)
```

---

## Fraud Scenarios in the Sample Data

**1. Account Takeover — Alice & Bob**
Alice and Bob share the same device, phone number, and home address.
One identity is synthetic. A single graph traversal from the shared device surfaces both accounts instantly.

**2. Money Laundering — Carol, Dave, Eve**
Funds cycle: A300 → A400 → A500 → A300.
This circular transfer loop is the layering stage of money laundering.
Neo4j finds the 3-cycle in one Cypher clause; SQL needs three self-joins.

**3. Mule Network — Frank & Grace**
Frank and Grace share contact details and route funds into Carol's network.
Graph analysis connects the mule accounts to the laundering ring even when the mules have no direct relationship.

---

## Useful Cypher Queries

**Show the whole graph**
```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 100;
```

**Find people sharing a device**
```cypher
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, d.device_id AS shared_device;
```

**Find circular money movement**
```cypher
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
RETURN path;
```

**Shortest path between two accounts**
```cypher
MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;
```

---

## Resetting the Database

```cypher
MATCH (n) DETACH DELETE n;
```

Then rerun the load commands from step 2 above.

---

## Neo4j Browser

Available at http://localhost:7474 while the container is running.
Credentials: `neo4j` / `password123`

---

## Neo4j Bloom (optional)

Bloom requires Enterprise Edition as a server plugin. To use it free, install Neo4j Desktop and connect it to the running container.

1. Download Neo4j Desktop — https://neo4j.com/download/
2. Add → Connect to Remote Instance
3. URL: `neo4j://localhost:7687` · Username: `neo4j` · Password: `password123`
4. Open → Neo4j Bloom
5. Import perspective: `bloom/fraud-detection-perspective.json`

---

## Teaching Takeaway

Graph databases are not better for everything.
They are better when **relationships are the main thing you need to query**.
