-- Simple relational schema for comparing the same fraud data in SQL.
-- This is not required to run the Neo4j demo.

CREATE TABLE people (
  person_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  risk_score INTEGER NOT NULL,
  device_id TEXT NOT NULL,
  phone_id TEXT NOT NULL,
  address_id TEXT NOT NULL
);

CREATE TABLE accounts (
  account_id TEXT PRIMARY KEY,
  person_id TEXT NOT NULL REFERENCES people(person_id),
  account_type TEXT NOT NULL,
  status TEXT NOT NULL,
  opened_date DATE NOT NULL
);

CREATE TABLE transactions (
  transaction_id TEXT PRIMARY KEY,
  from_account_id TEXT NOT NULL REFERENCES accounts(account_id),
  to_account_id TEXT REFERENCES accounts(account_id),
  amount NUMERIC NOT NULL,
  timestamp TEXT NOT NULL,
  channel TEXT NOT NULL,
  merchant_id TEXT
);

CREATE TABLE devices (
  device_id TEXT PRIMARY KEY,
  device_type TEXT NOT NULL,
  label TEXT NOT NULL
);

CREATE TABLE phone_numbers (
  phone_id TEXT PRIMARY KEY,
  phone_number TEXT NOT NULL
);

CREATE TABLE addresses (
  address_id TEXT PRIMARY KEY,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  country TEXT NOT NULL
);

CREATE TABLE merchants (
  merchant_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL
);

