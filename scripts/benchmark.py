"""
Tiny Neo4j query timing helper for the tutorial.

Usage:
  pip install neo4j
  python scripts/benchmark.py

Make sure Neo4j is running first:
  docker compose up -d
"""

from __future__ import annotations

import time

from neo4j import GraphDatabase


URI = "bolt://localhost:7687"
AUTH = ("neo4j", "password123")

QUERIES = {
    "shared_phone": """
        MATCH (p1:Person)-[:HAS_PHONE]->(ph:PhoneNumber)<-[:HAS_PHONE]-(p2:Person)
        WHERE p1.person_id < p2.person_id
        RETURN p1.name, p2.name, ph.phone_number
    """,
    "circular_transfers": """
        MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
                     -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
                     -[:SENT]->(:Transaction)-[:TO]->(a1)
        RETURN path
    """,
    "shortest_path": """
        MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
        MATCH path = shortestPath((start)-[*..8]-(end))
        RETURN path
    """,
}


def main() -> None:
    driver = GraphDatabase.driver(URI, auth=AUTH)
    with driver.session(database="neo4j") as session:
        for name, query in QUERIES.items():
            start = time.perf_counter()
            rows = list(session.run(query))
            elapsed_ms = (time.perf_counter() - start) * 1000
            print(f"{name}: {len(rows)} row(s), {elapsed_ms:.2f} ms")
    driver.close()


if __name__ == "__main__":
    main()

