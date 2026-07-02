// ============================================================
// Query Practice — Tutorial Demo Set
// ============================================================
// Three queries, one per difficulty tier, picked to click through live
// during the walkthrough: a simple lookup, an aggregation, and the fraud
// pattern this whole app is built around. Paste one at a time into Neo4j
// Browser (localhost:7474) after loading the data (01_constraints.cypher,
// 02_load_data.cypher).
//
// Every "Expected result" below was run against the live dataset, not
// guessed — if your numbers differ, the data was reloaded/regenerated
// since this was written.
// ============================================================


// ------------------------------------------------------------
// HOW TO READ THIS FILE
// ------------------------------------------------------------
//
// Picture the data as a corkboard covered in dots and string:
//   - A dot is a "thing" — a person, a bank account, a transaction,
//     a store, a phone number, a device, a home address.
//   - A piece of string is a relationship between two dots — "owns",
//     "sent", "paid", "lives at", "uses this phone".
//
// Quick translation guide for the technical words you'll see below:
//   MATCH        -> "find dots/strings shaped like this"
//   WHERE        -> "but only keep the ones where..."
//   RETURN       -> "show me..."
//   ORDER BY     -> "sort them by..."
//   SUM          -> "add them up"
// ------------------------------------------------------------


// ------------------------------------------------------------
// SIMPLE — a named lookup
// ------------------------------------------------------------

// 1. Show accounts owned by one person.
// In plain words: "Find the dot named Alice Martin, follow every 'owns'
// string leading out of her, and list the account dots on the other end."
MATCH (p:Person {name: "Alice Martin"})-[:OWNS]->(a:Account)
RETURN p.name AS person, a.account_id AS account, a.account_type AS type, a.status AS status;

// Expected result:
// Alice Martin owns A100 and A101.


// ------------------------------------------------------------
// MEDIUM — an aggregation
// ------------------------------------------------------------

// 2. Total amount sent out per account.
// In plain words: "Bundle every transaction by which account sent it,
// add up the dollar amounts in each bundle, biggest total first — like
// totaling receipts by category instead of listing each receipt."
MATCH (a:Account)-[:SENT]->(t:Transaction)
RETURN a.account_id AS account, sum(t.amount) AS total_sent
ORDER BY total_sent DESC;

// Expected result (highest to lowest):
// A700 (1750), A300 (1300), A400 (875), A500 (850), A600 (600),
// A100 (250), A200 (245.5), A800 (45), A101 (30).


// ------------------------------------------------------------
// HARD — the fraud pattern
// ------------------------------------------------------------

// 3. Circular money movement across three accounts.
// In plain words: "Look for money that travels in a loop — account A
// pays B, B pays C, and C pays back to A. This closed loop is a classic
// money-laundering red flag, and it's the same shape server.js checks
// on every transfer (see CYCLE_QUERY)."
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
WHERE a1.account_id < a2.account_id AND a1.account_id < a3.account_id
RETURN path;

// Expected result:
// A300 -> A400 -> A500 -> A300.