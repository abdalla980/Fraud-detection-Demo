// Suspicious pattern queries.

// 1. People sharing the same device.
MATCH (p1:Person)-[:USES_DEVICE]->(d:Device)<-[:USES_DEVICE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, d.device_id AS shared_device, d.label AS device_label;

// Expected result:
// Alice Martin and Bob Chen share D001.

// 2. People sharing the same phone number.
MATCH (p1:Person)-[:HAS_PHONE]->(ph:PhoneNumber)<-[:HAS_PHONE]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2, ph.phone_number AS shared_phone;

// Expected results:
// Alice Martin and Bob Chen share +1-555-0101.
// Frank Diaz and Grace Kim share +1-555-0199.

// 3. People sharing the same address.
MATCH (p1:Person)-[:LIVES_AT]->(ad:Address)<-[:LIVES_AT]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS person1, p2.name AS person2,
       ad.street + ", " + ad.city AS shared_address;

// 4. Two-hop transaction chains.
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
RETURN path
LIMIT 10;

// 5. Circular money movement across three accounts.
MATCH path = (a1:Account)-[:SENT]->(:Transaction)-[:TO]->(a2:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a3:Account)
             -[:SENT]->(:Transaction)-[:TO]->(a1)
WHERE a1.account_id < a2.account_id AND a1.account_id < a3.account_id
RETURN path;

// Expected result:
// A300 -> A400 -> A500 -> A300.

// 6. Accounts connected to high-risk people through shared contact details.
MATCH (p:Person)-[:OWNS]->(a:Account)
WHERE p.risk_score >= 75
MATCH (p)-[:HAS_PHONE|LIVES_AT|USES_DEVICE]->(shared)<-[:HAS_PHONE|LIVES_AT|USES_DEVICE]-(other:Person)
WHERE p <> other
RETURN p.name AS risky_person, a.account_id AS risky_account,
       labels(shared)[0] AS shared_type, other.name AS connected_person
ORDER BY risky_person;

