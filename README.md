# Fraud Detection with Neo4j

A self-contained demo for teaching graph databases through a fraud detection scenario.

> Which accounts look suspicious, and how are they connected?

---

## Requirements

- Docker Desktop (running)
- Node.js 18+

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

## Demo

Open two browser tabs:

| Tab | URL |
|-----|-----|
| Bank portal | http://localhost:8080/bank.html |
| Graph view  | http://localhost:8080 |

1. Open the bank portal as **Carol (A300)**
2. Click **Send Money** → send any amount to `A400 Dave Wilson`
3. Transaction is declined with a fraud alert after ~2s
4. Click **View Fraud Investigation** to see the money laundering ring in the graph

**Other demo accounts:**

| Account | Scenario |
|---------|----------|
| Alice (A100) | Shared identity alert when sending to A200 |
| Frank (A600) | Mule network alert when sending to A700 |

---

## Neo4j Browser

`http://localhost:7474` — credentials: `neo4j` / `password123`

---

## Data Model

**Nodes:** Person · Account · Transaction · Device · PhoneNumber · Address · Merchant

**Relationships:**
```
(:Person)-[:OWNS]->(:Account)
(:Account)-[:SENT]->(:Transaction)-[:TO]->(:Account)
(:Person)-[:USES_DEVICE]->(:Device)
(:Person)-[:HAS_PHONE]->(:PhoneNumber)
(:Person)-[:LIVES_AT]->(:Address)
(:Account)-[:PAID]->(:Merchant)
```

---

## Fraud Scenarios

**Account Takeover — Alice & Bob**
Alice and Bob share the same device, phone number, and address. A single graph traversal surfaces both accounts.

**Money Laundering — Carol, Dave, Eve**
Funds cycle: A300 → A400 → A500 → A300. Neo4j finds this 3-cycle in one Cypher clause; SQL needs three self-joins.

**Mule Network — Frank & Grace**
Frank and Grace share contact details and route funds into Carol's network. Graph analysis connects the mule accounts to the laundering ring with no direct relationship between them.

---

## Key Cypher Queries

**Full graph**
```cypher
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 100;
```

**People sharing a device**
```cypher
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name, p2.name, d.device_id;
```

**Circular money movement**
```cypher
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
RETURN path;
```

**Shortest path between two accounts**
```cypher
MATCH (s:Account {account_id: "A300"}), (e:Account {account_id: "A700"})
MATCH path = shortestPath((s)-[*..8]-(e))
RETURN path;
```

---

## Cypher Reference & Favorites

- `cypher/syntax-reference.html` — every query pattern used in this project (basic lookups, filtering, sorting, aggregation, and CRUD), each with a plain-English breakdown of the syntax and a verified expected result. Open it directly in a browser.
- `cypher/favorites-fraud.csv` — the same queries, importable into Neo4j Browser's Favorites panel (star icon in the sidebar) so they're one click away instead of copy-pasted each time.
- `cypher/favorites-fraud.cypher` — the same content as the CSV, in plain readable Cypher, if you just want to read through it or edit a query before regenerating the CSV.

---

## Reset

```cypher
MATCH (n) DETACH DELETE n;
```

Then rerun the load commands from step 2.

