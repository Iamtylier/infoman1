DROP DATABASE IF EXISTS eventhub_midterm;

-- Seed

CREATE DATABASE IF NOT EXISTS eventhub_midterm;
USE eventhub_midterm;
DROP TABLE IF EXISTS event_booking_flat;
CREATE TABLE event_booking_flat (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    booking_date DATE NOT NULL,
    organizer_id INT NOT NULL,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(100) NOT NULL,
    event_title VARCHAR(150) NOT NULL,
    venue_code VARCHAR(20) NOT NULL,
    venue_name VARCHAR(100) NOT NULL,
    venue_city VARCHAR(50) NOT NULL,
    venue_capacity INT NOT NULL,
    ticket_category VARCHAR(50) NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL,
    tickets_booked INT NOT NULL,
    speaker_list VARCHAR(255) NULL,
    PRIMARY KEY (booking_id, session_code)
);
INSERT INTO event_booking_flat
(booking_id, session_code, booking_date, organizer_id, organizer_name, organizer_email, event_title, venue_code, venue_name, venue_city, venue_capacity, ticket_category, ticket_price, tickets_booked, speaker_list)
VALUES
(101, 'SESS-A1', '2025-04-10', 1, 'Tech Forward PH', 'info@techforward.ph', 'Modern Web & DB Summit', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'Standard', 500.00, 4, 'Dr. Perez, Engr. Cruz'),
(101, 'SESS-A2', '2025-04-10', 1, 'Tech Forward PH', 'info@techforward.ph', 'Modern Web & DB Summit', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'VIP', 1200.00, 2, 'Engr. Cruz'),
(102, 'SESS-B1', '2025-04-12', 2, 'Green Earth Initiative', 'contact@greenearth.org', 'Urban Ecology Seminar', 'V-BAY', 'Bayview Convention Hall', 'Manila', 150, 'Standard', 350.00, 5, 'Prof. Santos'),
(103, 'SESS-A1', '2025-04-15', 3, 'Innovate Campus Lab', 'lead@innovatecampus.edu', 'AI & Cloud Infrastructure', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'Student', 250.00, 10, 'Dr. Perez, Ms. Lim'),
(104, 'SESS-C1', '2025-04-18', 2, 'Green Earth Initiative', 'contact@greenearth.org', 'Community Climate Action', 'V-BAY', 'Bayview Convention Hall', 'Manila', 150, 'Standard', 350.00, 3, 'Prof. Santos, Dr. Reyes'),
(105, 'SESS-D1', '2025-04-20', 4, 'Digital Health Alliance', 'care@digitalhealth.ph', 'Health Informatics 2025', 'V-PARK', 'Greenfield Innovation Center', 'Pasig', 80, 'VIP', 1500.00, 1, 'Dr. Aquino'),
(106, 'SESS-D2', '2025-04-22', 4, 'Digital Health Alliance', 'care@digitalhealth.ph', 'Telemedicine Implementation', 'V-PARK', 'Greenfield Innovation Center', 'Pasig', 80, 'Standard', 600.00, 6, 'Dr. Aquino, Engr. Tan');

-- Task 1

SELECT venue_code, venue_name, venue_capacity, COUNT(*) AS rows_carrying_venue
FROM event_booking_flat
GROUP BY venue_code, venue_name, venue_capacity;
DESCRIBE event_booking_flat;
SELECT * FROM event_booking_flat WHERE organizer_id = 3;
SELECT * FROM event_booking_flat WHERE speaker_list LIKE '%Ms. Lim%';

-- Task 2

CREATE TABLE organizers (
  organizer_id INT NOT NULL,
  organizer_name VARCHAR(100) NOT NULL,
  organizer_email VARCHAR(100) NOT NULL,
  PRIMARY KEY (organizer_id),
  CONSTRAINT uq_organizer_email UNIQUE (organizer_email)
);
CREATE TABLE venues (
  venue_code VARCHAR(20) NOT NULL,
  venue_name VARCHAR(100) NOT NULL,
  venue_city VARCHAR(50) NOT NULL,
  venue_capacity INT NOT NULL,
  PRIMARY KEY (venue_code),
  CONSTRAINT chk_venue_capacity CHECK (venue_capacity > 0)
);
CREATE TABLE bookings (
  booking_id INT NOT NULL,
  booking_date DATE NOT NULL,
  event_title VARCHAR(150) NOT NULL,
  organizer_id INT NOT NULL,
  venue_code VARCHAR(20) NOT NULL,
  PRIMARY KEY (booking_id),
  CONSTRAINT fk_bookings_organizer FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id),
  CONSTRAINT fk_bookings_venue FOREIGN KEY (venue_code) REFERENCES venues(venue_code)
);
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
CREATE TABLE speakers (
  speaker_id INT NOT NULL AUTO_INCREMENT,
  speaker_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (speaker_id),
  CONSTRAINT uq_speaker_name UNIQUE (speaker_name)
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
SHOW TABLES;
DESCRIBE organizers;
DESCRIBE venues;
DESCRIBE bookings;
DESCRIBE booking_sessions;
DESCRIBE speakers;
DESCRIBE session_speakers;

-- Task 3

INSERT INTO organizers (organizer_id, organizer_name, organizer_email)
SELECT DISTINCT organizer_id, organizer_name, organizer_email FROM event_booking_flat;
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
SELECT DISTINCT venue_code, venue_name, venue_city, venue_capacity FROM event_booking_flat;
INSERT INTO bookings (booking_id, booking_date, event_title, organizer_id, venue_code)
SELECT DISTINCT booking_id, booking_date, event_title, organizer_id, venue_code FROM event_booking_flat;
INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
SELECT booking_id, session_code, ticket_category, ticket_price, tickets_booked FROM event_booking_flat;
INSERT INTO speakers (speaker_name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.speaker_list, ',', nums.n), ',', -1))
FROM event_booking_flat f
JOIN (SELECT 1 AS n UNION ALL SELECT 2) nums
  ON nums.n <= 1 + LENGTH(f.speaker_list) - LENGTH(REPLACE(f.speaker_list, ',', ''))
WHERE f.speaker_list IS NOT NULL;
INSERT INTO session_speakers (booking_id, session_code, speaker_id)
SELECT DISTINCT f.booking_id, f.session_code, sp.speaker_id
FROM event_booking_flat f
JOIN (SELECT 1 AS n UNION ALL SELECT 2) nums
  ON nums.n <= 1 + LENGTH(f.speaker_list) - LENGTH(REPLACE(f.speaker_list, ',', ''))
JOIN speakers sp
  ON sp.speaker_name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.speaker_list, ',', nums.n), ',', -1))
WHERE f.speaker_list IS NOT NULL;
SELECT (SELECT COUNT(*) FROM organizers)        AS organizers,
       (SELECT COUNT(*) FROM venues)            AS venues,
       (SELECT COUNT(*) FROM bookings)          AS bookings,
       (SELECT COUNT(*) FROM booking_sessions)  AS booking_sessions,
       (SELECT COUNT(*) FROM speakers)          AS speakers,
       (SELECT COUNT(*) FROM session_speakers)  AS session_speakers;
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'Campus Innovation Hall', 'Quezon City', 200);
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-TEMP', 'Temporary Test Venue', 'Test City', 50);
SELECT * FROM venues;
SELECT booking_id, session_code, ticket_category, ticket_price,
       ROUND(ticket_price * 1.10, 2) AS new_price
FROM booking_sessions
WHERE ticket_category = 'VIP';
SELECT COUNT(*) AS rows_to_update FROM booking_sessions WHERE ticket_category = 'VIP';
UPDATE booking_sessions
SET ticket_price = ROUND(ticket_price * 1.10, 2)
WHERE ticket_category = 'VIP';
SELECT booking_id, session_code, ticket_category, ticket_price
FROM booking_sessions
WHERE ticket_category = 'VIP';
SELECT * FROM venues WHERE venue_code = 'V-TEMP';
SELECT COUNT(*) AS rows_to_delete FROM venues WHERE venue_code = 'V-TEMP';
DELETE FROM venues WHERE venue_code = 'V-TEMP';
SELECT * FROM venues WHERE venue_code = 'V-TEMP';

-- Task 4

SELECT booking_id, session_code, ticket_category, ticket_price, tickets_booked
FROM booking_sessions
WHERE (ticket_category = 'VIP' OR ticket_category = 'Standard')
  AND ticket_price >= 500
  AND tickets_booked >= 2;
SELECT booking_id,
       UPPER(event_title)                       AS title_upper,
       CHAR_LENGTH(event_title)                 AS title_length,
       DATE_FORMAT(booking_date, '%M %d, %Y')   AS booking_date_text,
       DAYNAME(booking_date)                    AS weekday,
       DATE_ADD(booking_date, INTERVAL 30 DAY)  AS followup_date
FROM bookings
ORDER BY booking_date;
SELECT speaker_id, speaker_name
FROM speakers
WHERE speaker_name LIKE 'Dr. %'
ORDER BY speaker_name;
SELECT ticket_category,
       COUNT(*)                          AS sessions,
       SUM(tickets_booked)               AS tickets_sold,
       SUM(ticket_price * tickets_booked) AS revenue
FROM booking_sessions
GROUP BY ticket_category
HAVING SUM(tickets_booked) >= 5
ORDER BY revenue DESC;

-- Task 5

SELECT b.booking_id, b.event_title, o.organizer_name, v.venue_name,
       bs.session_code, bs.ticket_category, bs.ticket_price, bs.tickets_booked,
       bs.ticket_price * bs.tickets_booked AS line_total
FROM bookings b
INNER JOIN organizers o       ON b.organizer_id = o.organizer_id
INNER JOIN venues v           ON b.venue_code   = v.venue_code
INNER JOIN booking_sessions bs ON b.booking_id  = bs.booking_id
ORDER BY b.booking_id, bs.session_code;
SELECT v.venue_code, v.venue_name, v.venue_city
FROM venues v
LEFT JOIN bookings b ON v.venue_code = b.venue_code
WHERE b.booking_id IS NULL;
SELECT v.venue_code, v.venue_name, b.booking_id, b.booking_date
FROM venues v
LEFT JOIN bookings b ON v.venue_code = b.venue_code
WHERE b.booking_date >= '2025-04-19'
ORDER BY v.venue_code, b.booking_id;
SELECT v.venue_code, v.venue_name, b.booking_id, b.booking_date
FROM venues v
LEFT JOIN bookings b ON v.venue_code = b.venue_code
                    AND b.booking_date >= '2025-04-19'
ORDER BY v.venue_code, b.booking_id;

-- Task 6

ALTER TABLE venues
  ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'MAINTENANCE', 'CLOSED'));
SELECT venue_code, venue_name, venue_status FROM venues;
SELECT venue_code, venue_status FROM venues WHERE venue_code = 'V-BAY';
UPDATE venues SET venue_status = 'MAINTENANCE' WHERE venue_code = 'V-BAY';
SELECT venue_code, venue_status FROM venues WHERE venue_code = 'V-BAY';
SELECT v.venue_code, v.venue_name, v.venue_status,
       COUNT(DISTINCT b.booking_id)                       AS bookings,
       COALESCE(SUM(bs.tickets_booked), 0)                AS tickets_sold,
       COALESCE(SUM(bs.ticket_price * bs.tickets_booked), 0) AS revenue
FROM venues v
LEFT JOIN bookings b          ON v.venue_code  = b.venue_code
LEFT JOIN booking_sessions bs ON b.booking_id  = bs.booking_id
GROUP BY v.venue_code, v.venue_name, v.venue_status
ORDER BY revenue DESC;

-- Constraint tests (these fail on purpose, so they run last)

INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
VALUES (101, 'SESS-A9', 'Standard', -100.00, 1);

UPDATE venues SET venue_status = 'RETIRED' WHERE venue_code = 'V-PARK';