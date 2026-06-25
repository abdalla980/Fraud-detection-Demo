// Create uniqueness constraints.
// These make MERGE safer and help Neo4j load the CSV data faster.

CREATE CONSTRAINT person_id_unique IF NOT EXISTS
FOR (p:Person) REQUIRE p.person_id IS UNIQUE;

CREATE CONSTRAINT account_id_unique IF NOT EXISTS
FOR (a:Account) REQUIRE a.account_id IS UNIQUE;

CREATE CONSTRAINT transaction_id_unique IF NOT EXISTS
FOR (t:Transaction) REQUIRE t.transaction_id IS UNIQUE;

CREATE CONSTRAINT device_id_unique IF NOT EXISTS
FOR (d:Device) REQUIRE d.device_id IS UNIQUE;

CREATE CONSTRAINT phone_id_unique IF NOT EXISTS
FOR (ph:PhoneNumber) REQUIRE ph.phone_id IS UNIQUE;

CREATE CONSTRAINT address_id_unique IF NOT EXISTS
FOR (ad:Address) REQUIRE ad.address_id IS UNIQUE;

CREATE CONSTRAINT merchant_id_unique IF NOT EXISTS
FOR (m:Merchant) REQUIRE m.merchant_id IS UNIQUE;

