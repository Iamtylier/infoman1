# INFOMAN1 — Midterm Practical Assessment: Answer Document

**Name:** Tylier Dolipas  
**Student ID:** ____________________  
**Repository URL:** https://github.com/lamtylier/infoman1  
**Date Submitted:** ____________________

---

## Task 1: Normalization Audit & 3NF Decomposition

### Approach
I looked at the flat table and checked which columns repeat. Then I split it step by step: 1NF, 2NF, then 3NF.

### 1. Data Anomalies in `event_booking_flat`

- **Update Anomaly:** Venue V-METRO is saved on 3 rows (booking 101 twice and booking 103). If its capacity changes, I must update all 3 rows. If I miss one, the data conflicts.
- **Insertion Anomaly:** All columns except `speaker_list` are NOT NULL. I can't add a new venue (like V-CAMPUS) until there is a booking for it.
- **Deletion Anomaly:** Booking 103 / SESS-A1 is the only row for organizer Innovate Campus Lab and speaker Ms. Lim. If I delete it, both are gone.

### 2. Functional Dependencies
- `booking_id -> booking_date, organizer_id, event_title, venue_code`
- `organizer_id -> organizer_name, organizer_email`
- `venue_code -> venue_name, venue_city, venue_capacity`
- `(booking_id, session_code) -> ticket_category, ticket_price, tickets_booked`

### 3. Normalization Progression

- **First Normal Form (1NF)** (include how speakers become atomic rows): I split `speaker_list` so each speaker gets their own row. The 7 rows become 11, with one value in every cell.
- **Second Normal Form (2NF):** Booking details depend only on `booking_id`, so I moved them to `bookings`. Ticket details stay in `booking_sessions`.
- **Third Normal Form (3NF):** Organizer and venue details depend on `organizer_id` and `venue_code`, not on the booking. I moved them to `organizers` and `venues`, and speaker names to `speakers`.

### 4. Final Relational Schema Notation

```
organizers(<u>organizer_id</u>, organizer_name, organizer_email)
venues(<u>venue_code</u>, venue_name, venue_city, venue_capacity)
bookings(<u>booking_id</u>, booking_date, event_title, organizer_id [FK], venue_code [FK])
booking_sessions(<u>booking_id</u> [FK], <u>session_code</u>, ticket_category, ticket_price, tickets_booked)
speakers(<u>speaker_id</u>, speaker_name)
session_speakers(<u>booking_id</u> [FK], <u>session_code</u> [FK], <u>speaker_id</u> [FK])
```

### Evidence
- Update: V-METRO is on bookings 101 and 103.
- Insert: `DESCRIBE` shows NOT NULL on every column except `speaker_list`.
- Delete: booking 103 / SESS-A1 is the only row with organizer 3 and Ms. Lim.

```
```

### Reflection
Why does the many-to-many relationship between sessions and speakers require a junction table instead of another column?

A session can have many speakers and a speaker can be in many sessions. One column can't hold all of them cleanly. A junction table keeps one row for each session-speaker pair.

---

## Task 2: DDL Implementation with Constraints

### Approach
Every table has a primary key and the tables are linked with foreign keys. I used NOT NULL on important columns, UNIQUE on emails and speaker names, DEFAULT 'Standard' on ticket category, and CHECK so capacity, price and tickets can't be bad values. Prices are DECIMAL and dates are DATE.

### Code / Query Used
(Full script is in `task2_schema_ddl.sql`)

```sql
CREATE TABLE booking_sessions (
  booking_id INT NOT NULL,
  session_code VARCHAR(20) NOT NULL,
  ticket_category VARCHAR(50) NOT NULL DEFAULT 'Standard',
  ticket_price DECIMAL(8,2) NOT NULL,
  tickets_booked INT NOT NULL,
  PRIMARY KEY (booking_id, session_code),
  CONSTRAINT fk_sessions_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0),
  CONSTRAINT chk_tickets_booked CHECK (tickets_booked > 0)
);

CREATE TABLE session_speakers (
  booking_id INT NOT NULL,
  session_code VARCHAR(20) NOT NULL,
  speaker_id INT NOT NULL,
  PRIMARY KEY (booking_id, session_code, speaker_id),
  CONSTRAINT fk_ss_session FOREIGN KEY (booking_id, session_code)
    REFERENCES booking_sessions(booking_id, session_code),
  CONSTRAINT fk_ss_speaker FOREIGN KEY (speaker_id) REFERENCES speakers(speaker_id)
);
```

### Evidence: Table Verification (SHOW TABLES / DESCRIBE)

```sql
SHOW TABLES;
DESCRIBE booking_sessions;
```
```
```

### Reflection
Which table in your schema needed a composite primary key, and why?

`booking_sessions` needed `(booking_id, session_code)` because SESS-A1 is used in bookings 101 and 103, so the code alone isn't unique. `session_speakers` also needed a composite key because each row is a session and speaker pair.

---

## Task 3: Data Migration & Safe DML Operations

### Approach
I filled the parent tables first (organizers, venues, bookings), then booking_sessions, so the foreign keys work. To split the speakers I used `SUBSTRING_INDEX` and `TRIM`. Then I added the venues V-CAMPUS and V-TEMP.

### Code / Query Used
(Full script is in `task3_dml_operations.sql`)

```sql
INSERT INTO speakers (speaker_name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.speaker_list, ',', nums.n), ',', -1))
FROM event_booking_flat f
JOIN (SELECT 1 AS n UNION ALL SELECT 2) nums
  ON nums.n <= 1 + LENGTH(f.speaker_list) - LENGTH(REPLACE(f.speaker_list, ',', ''))
WHERE f.speaker_list IS NOT NULL;

INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'Campus Innovation Hall', 'Quezon City', 200);
```

Row counts after migration (organizers, venues, bookings, sessions, speakers, session_speakers):
```
```

### Safe Change Loop: 10% Ticket Price Increase
- **Step 1 (Preview Rows):**
  ```sql
  SELECT booking_id, session_code, ticket_category, ticket_price,
         ROUND(ticket_price * 1.10, 2) AS new_price
  FROM booking_sessions WHERE ticket_category = 'VIP';
  ```
- **Step 2 (Confirm Target Count):** 2 rows (VIP tickets).
- **Step 3 (Execute UPDATE):**
  ```sql
  UPDATE booking_sessions
  SET ticket_price = ROUND(ticket_price * 1.10, 2)
  WHERE ticket_category = 'VIP';
  ```
- **Step 4 (Verify Changes):**
  ```sql
  SELECT booking_id, session_code, ticket_category, ticket_price
  FROM booking_sessions WHERE ticket_category = 'VIP';
  ```

### Safe Change Loop: DELETE of `V-TEMP`
- **Step 1 (Preview Rows):**
  ```sql
  SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  ```
- **Step 2 (Confirm Target Count):** 1 row.
- **Step 3 (Execute DELETE):**
  ```sql
  DELETE FROM venues WHERE venue_code = 'V-TEMP';
  ```
- **Step 4 (Verify Changes):**
  ```sql
  SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  ```
  Empty set.

### Evidence: Constraint Protection Verification

- **Invalid SQL Statement:**
  ```sql
  INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
  VALUES (101, 'SESS-A9', 'Standard', -100.00, 1);
  ```
- **MySQL Error Message Received:**
  ```
  ```

### Reflection
Why is the `DELETE` targeted by primary key rather than by venue name?

The primary key matches only one row. A venue name can be repeated or changed, so I might delete the wrong rows.

---

## Task 4: Filtering, Functions & Aggregate Analytics

### Approach
I used parentheses in Query 1 so the OR is checked first. Query 2 uses string and date functions. Query 3 uses LIKE with `%`. Query 4 groups by ticket category and filters the groups.

### Query 1: Compound Logical Filtering with Precedence
**SQL Query:**
```sql
SELECT booking_id, session_code, ticket_category, ticket_price, tickets_booked
FROM booking_sessions
WHERE (ticket_category = 'VIP' OR ticket_category = 'Standard')
  AND ticket_price >= 500
  AND tickets_booked >= 2;
```
**Output:**
```
```

### Query 2: Scalar String & Date Functions
**SQL Query:**
```sql
SELECT booking_id,
       UPPER(event_title)                       AS title_upper,
       CHAR_LENGTH(event_title)                 AS title_length,
       DATE_FORMAT(booking_date, '%M %d, %Y')   AS booking_date_text,
       DAYNAME(booking_date)                    AS weekday,
       DATE_ADD(booking_date, INTERVAL 30 DAY)  AS followup_date
FROM bookings
ORDER BY booking_date;
```
**Output:**
```
```

### Query 3: Pattern Matching with LIKE Wildcards
**SQL Query:**
```sql
SELECT speaker_id, speaker_name
FROM speakers
WHERE speaker_name LIKE 'Dr. %'
ORDER BY speaker_name;
```
**Output:**
```
```

### Query 4: GROUP BY and HAVING Summary
**SQL Query:**
```sql
SELECT ticket_category,
       COUNT(*)                           AS sessions,
       SUM(tickets_booked)                AS tickets_sold,
       SUM(ticket_price * tickets_booked) AS revenue
FROM booking_sessions
GROUP BY ticket_category
HAVING SUM(tickets_booked) >= 5
ORDER BY revenue DESC;
```
**Output:**
```
```

### Reflection
Why does Query 4 filter with `HAVING` instead of `WHERE`?

`WHERE` filters rows before grouping, so it can't use `SUM()`. `HAVING` filters the groups after `GROUP BY`.

---

## Task 5: Multi-Table Joins & Outer Join Diagnostics

### Approach
I started from `bookings` and joined `organizers` (organizer_id), `venues` (venue_code) and `booking_sessions` (booking_id). For unbooked venues I started from `venues` and used a LEFT JOIN to `bookings`.

### 1. Multi-Table INNER JOIN
**SQL Query:**
```sql
SELECT b.booking_id, b.event_title, o.organizer_name, v.venue_name,
       bs.session_code, bs.ticket_category, bs.ticket_price, bs.tickets_booked,
       bs.ticket_price * bs.tickets_booked AS line_total
FROM bookings b
INNER JOIN organizers o        ON b.organizer_id = o.organizer_id
INNER JOIN venues v            ON b.venue_code   = v.venue_code
INNER JOIN booking_sessions bs ON b.booking_id   = bs.booking_id
ORDER BY b.booking_id, bs.session_code;
```
**Output:**
```
```

### 2. Finding Unbooked Venues (LEFT JOIN ... IS NULL)
**SQL Query:**
```sql
SELECT v.venue_code, v.venue_name, v.venue_city
FROM venues v
LEFT JOIN bookings b ON v.venue_code = b.venue_code
WHERE b.booking_id IS NULL;
```
**Output:**
```
```

### 3. The "Silent Inner Join" Trap Comparison
- **Version A (Flawed WHERE filter):**
  ```sql
  SELECT v.venue_code, v.venue_name, b.booking_id, b.booking_date
  FROM venues v
  LEFT JOIN bookings b ON v.venue_code = b.venue_code
  WHERE b.booking_date >= '2025-04-19'
  ORDER BY v.venue_code, b.booking_id;
  ```
  *Result / Behavior:* Only 2 rows (V-PARK). The other venues are gone.

- **Version B (Correct ON condition):**
  ```sql
  SELECT v.venue_code, v.venue_name, b.booking_id, b.booking_date
  FROM venues v
  LEFT JOIN bookings b ON v.venue_code = b.venue_code
                      AND b.booking_date >= '2025-04-19'
  ORDER BY v.venue_code, b.booking_id;
  ```
  *Result / Behavior:* 5 rows. All venues stay, and the ones with no match show NULL.

- **Technical Explanation:** A venue with no match has NULL in the booking columns. When the date test is in `WHERE`, `NULL >= '2025-04-19'` is not true, so those rows are removed and the LEFT JOIN acts like an INNER JOIN. In `ON`, the test only decides which bookings match, so every venue is kept.

### Reflection
Why is `= NULL` the wrong way to find unbooked venues, and what is the correct test?

NULL means unknown, so `= NULL` is never true. The correct test is `IS NULL`.

---

## Task 6: Schema Evolution & Cross-Week Synthesis

### Approach
I added `venue_status` to `venues` because it describes the venue. The allowed values are ACTIVE, MAINTENANCE and CLOSED, and the default is ACTIVE.

### 1. ALTER TABLE Statement & Status Constraint
```sql
ALTER TABLE venues
  ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'MAINTENANCE', 'CLOSED'));
```

### 2. Targeted Primary-Key UPDATE
```sql
UPDATE venues SET venue_status = 'MAINTENANCE' WHERE venue_code = 'V-BAY';
```

### 3. Constraint Test (invalid status)
- **Invalid SQL Statement:**
  ```sql
  UPDATE venues SET venue_status = 'RETIRED' WHERE venue_code = 'V-PARK';
  ```
- **MySQL Error Message Received:**
  ```
  ```

### 4. Integrated Synthesis Report Query
**SQL Query:**
```sql
SELECT v.venue_code, v.venue_name, v.venue_status,
       COUNT(DISTINCT b.booking_id)                          AS bookings,
       COALESCE(SUM(bs.tickets_booked), 0)                   AS tickets_sold,
       COALESCE(SUM(bs.ticket_price * bs.tickets_booked), 0) AS revenue
FROM venues v
LEFT JOIN bookings b          ON v.venue_code = b.venue_code
LEFT JOIN booking_sessions bs ON b.booking_id = bs.booking_id
GROUP BY v.venue_code, v.venue_name, v.venue_status
ORDER BY revenue DESC;
```
**Output:**
```
```

### Reflection
Why does adding `NOT NULL DEFAULT 'ACTIVE'` succeed on a table that already holds rows?

MySQL gives every existing row the default value 'ACTIVE', so no row is left NULL.

---

## Task 7: Self-Review & Reflection

### Self-Audit Checklist
- [ ] All three anomalies (update, insert, delete) clearly explained with examples
- [ ] Schema systematically normalized from flat table $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF
- [ ] Speakers modeled with a junction table
- [ ] All primary keys underlined and foreign keys marked in schema notation
- [ ] DDL created with `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK` constraints
- [ ] 4-step Safe Change Loop followed for the `UPDATE` and the `DELETE`
- [ ] Invalid insert correctly triggered and documented MySQL constraint error
- [ ] Query 1 properly uses parentheses for `AND` / `OR` operator precedence
- [ ] Query 4 properly uses `HAVING` instead of `WHERE` for aggregate filter
- [ ] Outer join missing-record query uses `IS NULL` check
- [ ] Silent inner join trap clearly explained with both query variations
- [ ] `ALTER TABLE` successfully executed and invalid status rejected
- [ ] Integrated synthesis report combines joins, aggregation, grouping, and ordering

### Concluding Reflection
1. What was the most significant challenge when decomposing the unnormalized flat table into 3NF, and how did separating entities improve data integrity?

   The hardest part was the speakers and the composite key, because `session_code` repeats across bookings. After splitting the tables, each fact is saved only once, so changing a venue or organizer is one update, and deleting a booking doesn't erase them.

2. What are the practical performance tradeoffs between keeping a single flat table versus querying multiple normalized tables using `JOIN`s in a high-traffic production environment?

   A flat table is faster to read because it needs no joins, but it repeats data and is harder to update safely. Normalized tables keep data consistent, but they need JOINs, which can be slower unless the columns are indexed.