// Run this after 01_constraints.cypher.
// The CSV files are mounted into Neo4j's import directory by docker-compose.yml.

LOAD CSV WITH HEADERS FROM 'file:///devices.csv' AS row
MERGE (d:Device {device_id: row.device_id})
SET d.device_type = row.device_type,
    d.label = row.label;

LOAD CSV WITH HEADERS FROM 'file:///phone_numbers.csv' AS row
MERGE (ph:PhoneNumber {phone_id: row.phone_id})
SET ph.phone_number = row.phone_number;

LOAD CSV WITH HEADERS FROM 'file:///addresses.csv' AS row
MERGE (ad:Address {address_id: row.address_id})
SET ad.street = row.street,
    ad.city = row.city,
    ad.country = row.country;

LOAD CSV WITH HEADERS FROM 'file:///merchants.csv' AS row
MERGE (m:Merchant {merchant_id: row.merchant_id})
SET m.name = row.name,
    m.category = row.category;

LOAD CSV WITH HEADERS FROM 'file:///people.csv' AS row
MERGE (p:Person {person_id: row.person_id})
SET p.name = row.name,
    p.risk_score = toInteger(row.risk_score)
WITH p, row
MATCH (d:Device {device_id: row.device_id})
MATCH (ph:PhoneNumber {phone_id: row.phone_id})
MATCH (ad:Address {address_id: row.address_id})
MERGE (p)-[:USES_DEVICE]->(d)
MERGE (p)-[:HAS_PHONE]->(ph)
MERGE (p)-[:LIVES_AT]->(ad);

LOAD CSV WITH HEADERS FROM 'file:///accounts.csv' AS row
MERGE (a:Account {account_id: row.account_id})
SET a.account_type = row.account_type,
    a.status = row.status,
    a.opened_date = date(row.opened_date)
WITH a, row
MATCH (p:Person {person_id: row.person_id})
MERGE (p)-[:OWNS]->(a);

LOAD CSV WITH HEADERS FROM 'file:///transactions.csv' AS row
MERGE (t:Transaction {transaction_id: row.transaction_id})
SET t.amount = toFloat(row.amount),
    t.timestamp = datetime(row.timestamp),
    t.channel = row.channel
WITH t, row
MATCH (from:Account {account_id: row.from_account_id})
MERGE (from)-[:SENT]->(t)
WITH t, row, from
FOREACH (_ IN CASE WHEN row.to_account_id <> '' THEN [1] ELSE [] END |
  MERGE (to:Account {account_id: row.to_account_id})
  MERGE (t)-[:TO]->(to)
)
FOREACH (_ IN CASE WHEN row.merchant_id <> '' THEN [1] ELSE [] END |
  MERGE (m:Merchant {merchant_id: row.merchant_id})
  MERGE (from)-[:PAID {
    transaction_id: row.transaction_id,
    amount: toFloat(row.amount),
    timestamp: datetime(row.timestamp)
  }]->(m)
);

