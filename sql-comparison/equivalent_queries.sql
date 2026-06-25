-- Example SQL queries that roughly match the Cypher demo queries.
-- Main teaching point: SQL can do this, but relationship-heavy questions
-- become join-heavy quickly.

-- People sharing a phone number.
SELECT
  p1.name AS person1,
  p2.name AS person2,
  ph.phone_number AS shared_phone
FROM people p1
JOIN people p2
  ON p1.phone_id = p2.phone_id
 AND p1.person_id < p2.person_id
JOIN phone_numbers ph
  ON ph.phone_id = p1.phone_id;

-- Circular money movement across three accounts.
SELECT
  t1.from_account_id AS account_1,
  t1.to_account_id AS account_2,
  t2.to_account_id AS account_3,
  t3.to_account_id AS back_to_account_1,
  t1.transaction_id AS transaction_1,
  t2.transaction_id AS transaction_2,
  t3.transaction_id AS transaction_3
FROM transactions t1
JOIN transactions t2
  ON t1.to_account_id = t2.from_account_id
JOIN transactions t3
  ON t2.to_account_id = t3.from_account_id
WHERE t3.to_account_id = t1.from_account_id;

-- A chain from A700 to A300.
SELECT
  t.transaction_id,
  t.from_account_id,
  t.to_account_id,
  t.amount
FROM transactions t
WHERE t.from_account_id = 'A700'
  AND t.to_account_id = 'A300';

-- In Neo4j, the equivalent shortest path query is much shorter:
-- MATCH (start:Account {account_id: "A300"}), (end:Account {account_id: "A700"})
-- MATCH path = shortestPath((start)-[*..8]-(end))
-- RETURN path;

