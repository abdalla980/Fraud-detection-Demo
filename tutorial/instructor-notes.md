# Instructor Notes

A step-by-step guide to explaining each part of the tutorial.

---

## Step 1 — Docker + Neo4j Browser

When students run `docker compose up -d`, Docker pulls a Neo4j container and starts it. Neo4j is the graph database — it stores nodes and relationships. The browser at `localhost:7474` is a web UI that lets you run queries against it. Nothing is installed on their machine permanently, Docker handles everything.

---

## Step 2 — Loading the data

There are two Cypher files they paste in order:

- `01_constraints.cypher` — tells Neo4j "account_id must be unique, person_id must be unique." This prevents duplicate data if they accidentally load twice.
- `02_load_data.cypher` — reads the CSV files from the `data/` folder and creates all the nodes and relationships. The `data/` folder is mounted into the Docker container so Neo4j can see it.

After loading they run a count query to confirm it worked. They should see 8 people, 9 accounts, 12 transactions, etc.

---

## Step 3 — Basic query

```cypher
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 50
```

This says "find anything connected to anything, show me 50." Neo4j Browser renders it as a visual graph automatically. This is the moment students see the graph for the first time — good time to point out nodes (circles) vs relationships (arrows).

---

## Step 4 — Shared device pattern

This is the account takeover fraud. Alice and Bob share the same device. The query finds two people who both point to the same device node. Explain it as: "in a real bank, if two accounts log in from the same phone, that's suspicious — one of them might be a fake identity."

---

## Step 5 — Shared phone pattern

Same idea but with phone numbers. Alice & Bob share one, Frank & Grace share another. Two separate fraud rings showing up with the same query shape.

---

## Step 6 — Circular transfer

This is the money laundering scenario. The query follows the chain: Account → Transaction → Account → Transaction → Account → Transaction → back to the start. If it loops, that's layering — money going in circles to obscure its origin.

Key teaching point: SQL would need three self-joins to find this. Cypher just says "find a path that comes back to itself."

---

## Step 7 — Shortest path

This connects the two fraud rings. A300 (Carol, money laundering) and A700 (Grace, mule network) look unrelated, but the graph finds the shortest connection between them. This shows students that graph databases are good at revealing hidden connections across the whole dataset, not just within one scenario.

---

## Step 8 — SQL comparison

Open `sql-comparison/equivalent_queries.sql` side by side with the Cypher. The circular transfer in SQL is ugly — three self-joins with aliased tables. The Cypher is one readable pattern.

Discussion question: "which one matches how you think about the problem?"

---

## Step 9 — GenAI exercise

Students ask ChatGPT or Claude to generate a new fraud scenario as CSV rows matching the project's format, then load it into Neo4j and write a query to find it. This ties the whole session together — they've gone from running queries to creating data and querying it themselves.

---

## Troubleshooting

The `troubleshooting.md` file covers the 6 most common issues: port already in use, login fails, data loaded twice, CSV not found, slow query, Python driver missing. Most issues resolve with:

```powershell
docker compose down -v
docker compose up -d
```

---

## Core message

Graph databases don't make you smarter — they make relationship queries look like the question you're actually asking. The circular transfer query literally looks like a circle.
