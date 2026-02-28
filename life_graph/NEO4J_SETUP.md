# LifeGraph – Neo4j Setup & Data Seeding

## Step 1: Setup and Environment

### Option A: Neo4j Desktop (Local)

1. Download [Neo4j Desktop](https://neo4j.com/download/).
2. Install and launch the application.
3. Create a new Project (clicked "New" -> "Create Project").
4. Add a Local DBMS (Database Management System) and set a password (remember this!).
5. Start the database.
6. Open "Neo4j Browser".

### Option B: Neo4j AuraDB (Cloud - Free Tier)

1. Go to [Neo4j AuraDB](https://neo4j.com/cloud/aura/).
2. Sign up and create a free instance.
3. Save the connection URI (e.g., `neo4j+s://xxx.databases.neo4j.io`) and the password.

---

## Step 2: Data Creation (The "Seed" Data)

Copy and paste the following Cypher query into your Neo4j Browser to seed the database with People, Events, Locations, and Relationships.

```cypher
// Clear existing data (Optional: Use with caution)
MATCH (n) DETACH DELETE n;

// 1. Create Locations
CREATE
  (loc_nyc:Location {city: "New York", venue_name: "Central Park Event Hall"}),
  (loc_la:Location {city: "Los Angeles", venue_name: "Grand Hotel"}),
  (loc_sf:Location {city: "San Francisco", venue_name: "Golden Gate Park"}),
  (loc_chi:Location {city: "Chicago", venue_name: "The Bean Plaza"});

// 2. Create People
CREATE
  (alice:Person {name: "Alice", birth_date: date("1990-05-15"), gender: "Female", email: "alice@example.com"}),
  (bob:Person {name: "Bob", birth_date: date("1988-08-20"), gender: "Male", email: "bob@example.com"}),
  (charlie:Person {name: "Charlie", birth_date: date("1992-11-10"), gender: "Male", email: "charlie@example.com"}),
  (diana:Person {name: "Diana", birth_date: date("1965-03-25"), gender: "Female", email: "diana@example.com"}),
  (edward:Person {name: "Edward", birth_date: date("1960-07-30"), gender: "Male", email: "edward@example.com"}),
  (frank:Person {name: "Frank", birth_date: date("1995-12-05"), gender: "Male", email: "frank@example.com"}),
  (grace:Person {name: "Grace", birth_date: date("1990-05-20"), gender: "Female", email: "grace@example.com"});

// 3. Create Events
CREATE
  (evt_birthday_alice:Event {type: "Birthday", title: "Alice's 30th Birthday", date: date("2020-05-15")}),
  (evt_wedding:Event {type: "Marriage", title: "Alice & Bob Wedding", date: date("2022-06-01")}),
  (evt_reunion:Event {type: "Gathering", title: "Smith Family Reunion", date: date("2023-08-15")}),
  (evt_concert:Event {type: "Concert", title: "Summer Rock Fest", date: date("2023-07-10")});

// 4. Create Relationships: FAMILY_MEMBER
CREATE
  (edward)-[:FAMILY_MEMBER {relationship_type: "Father"}]->(alice),
  (diana)-[:FAMILY_MEMBER {relationship_type: "Mother"}]->(alice),
  (alice)-[:FAMILY_MEMBER {relationship_type: "Daughter"}]->(edward),
  (alice)-[:FAMILY_MEMBER {relationship_type: "Daughter"}]->(diana),
  (charlie)-[:FAMILY_MEMBER {relationship_type: "Cousin"}]->(alice),
  (frank)-[:FAMILY_MEMBER {relationship_type: "Brother"}]->(alice);

// 5. Create Relationships: FRIEND
CREATE
  (alice)-[:FRIEND {since_year: 2010}]->(grace),
  (bob)-[:FRIEND {since_year: 2012}]->(charlie);

// 6. Create Relationships: MARRIED_TO (and link to Marriage Event)
CREATE
  (alice)-[:MARRIED_TO]->(bob),
  (bob)-[:MARRIED_TO]->(alice);

// 7. Connect Events to Locations
CREATE
  (evt_birthday_alice)-[:HELD_AT]->(loc_nyc),
  (evt_wedding)-[:HELD_AT]->(loc_sf),
  (evt_reunion)-[:HELD_AT]->(loc_la),
  (evt_concert)-[:HELD_AT]->(loc_chi);

// 8. Connect People to Events (ATTENDED)
CREATE
  (alice)-[:ATTENDED {role: "Host"}]->(evt_birthday_alice),
  (grace)-[:ATTENDED {role: "Guest"}]->(evt_birthday_alice),
  (bob)-[:ATTENDED {role: "Guest"}]->(evt_birthday_alice),

  (alice)-[:ATTENDED {role: "Bride"}]->(evt_wedding),
  (bob)-[:ATTENDED {role: "Groom"}]->(evt_wedding),
  (edward)-[:ATTENDED {role: "Guest"}]->(evt_wedding),
  (diana)-[:ATTENDED {role: "Guest"}]->(evt_wedding),
  (charlie)-[:ATTENDED {role: "Guest"}]->(evt_wedding),
  (grace)-[:ATTENDED {role: "Bridesmaid"}]->(evt_wedding),

  (edward)-[:ATTENDED {role: "Organizer"}]->(evt_reunion),
  (diana)-[:ATTENDED {role: "Guest"}]->(evt_reunion),
  (alice)-[:ATTENDED {role: "Guest"}]->(evt_reunion),
  (frank)-[:ATTENDED {role: "Guest"}]->(evt_reunion),
  (charlie)-[:ATTENDED {role: "Guest"}]->(evt_reunion);

RETURN "Database seeded successfully!" as Result;
```

---

## Step 3: Useful Queries

### 1. The "Upcoming Birthday" Search

Find all friends/family with birthdays in May (Month 5).

```cypher
MATCH (p:Person)
WHERE p.birth_date.month = 5
RETURN p.name, p.birth_date
```

### 2. The "Shared Memories" Search

Find events that Person 'Alice' and Person 'Grace' both attended.

```cypher
MATCH (p1:Person {name: "Alice"})-[:ATTENDED]->(e:Event)<-[:ATTENDED]-(p2:Person {name: "Grace"})
RETURN e.title, e.date, e.type
```

### 3. The "Family Reunion" Search

Find all events where 'Charlie's cousin was present.

```cypher
MATCH (charlie:Person {name: "Charlie"})-[:FAMILY_MEMBER {relationship_type: "Cousin"}]->(cousin:Person)-[:ATTENDED]->(e:Event)
RETURN cousin.name, e.title, e.date
```
