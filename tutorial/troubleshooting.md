# Troubleshooting

## Docker says the port is already in use

Neo4j uses ports `7474` and `7687`.

Check if another Neo4j container is already running:

```bash
docker ps
```

Stop the old container if needed:

```bash
docker compose down
```

Then start again:

```bash
docker compose up -d
```

## Neo4j Browser does not open

Wait 20-30 seconds after starting the container, then refresh:

<http://localhost:7474>

Check the logs:

```bash
docker compose logs neo4j
```

## Login fails

Use:

```text
Username: neo4j
Password: password123
```

If you changed the password before, remove the Docker volume and restart:

```bash
docker compose down -v
docker compose up -d
```

This deletes the local Neo4j database volume.

## LOAD CSV cannot find the file

Make sure you started Neo4j from the project root folder:

```bash
docker compose up -d
```

The `data/` folder is mounted into Neo4j as the import folder. In Cypher, files
are loaded like this:

```cypher
LOAD CSV WITH HEADERS FROM 'file:///people.csv' AS row
RETURN row
LIMIT 5;
```

## Constraint already exists

This is usually fine. The constraint file uses `IF NOT EXISTS`, so rerunning it
should not break anything.

## Data loaded twice

Most loading queries use `MERGE`, so duplicate nodes are unlikely. To reset the
database completely, run:

```cypher
MATCH (n) DETACH DELETE n;
```

Then rerun:

```text
cypher/01_constraints.cypher
cypher/02_load_data.cypher
```

## Query returns no rows

Check spelling and capitalization. For example:

```cypher
MATCH (a:Account {account_id: "A300"})
RETURN a;
```

`A300` works, but `a300` does not.

## Shortest path query is slow or too broad

Always include a maximum path length in beginner demos:

```cypher
MATCH path = shortestPath((start)-[*..8]-(end))
RETURN path;
```

Avoid unbounded paths like `[*]` on larger graphs.

## Python benchmark script cannot import neo4j

Install the Neo4j Python driver:

```bash
pip install neo4j
```

Then run:

```bash
python scripts/benchmark.py
```

