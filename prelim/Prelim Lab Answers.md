INFOMAN1 Prelim Lab Exam - Answer Document

ToolShare Neighborhood Tool Library

-- Design Summary (Tasks 1-2)

Four entities came from the spec: Member, Tool, Certification, and StorageLocation. Each has its own natural identifier (member_id, tool_id, cert_id, location_code), so no weak entities were needed.

Three relationships were many-to-many: Member borrows Tool, Tool requires Certification, and Member completes Certification. Each of these became its own table: Borrowing, ToolCertification, and MemberCertification.

Borrowing needed a surrogate key (borrowing_id) instead of a composite key, because a member can borrow the same tool more than once over time - a composite key on just member_id and tool_id could not tell two separate borrowing events apart. ToolCertification and MemberCertification did not need a surrogate key, since a tool only needs to require a given certification once, and a member only completes a given certification once - so their composite keys work fine as-is.

The fourth relationship, StorageLocation stores Tool, was already one-to- many, so it just became a plain foreign key: Tool.location_code, which is NOT NULL because every tool must have a location.

-- Data Type Notes (Task 3)

Phone numbers are stored as VARCHAR, not a number type, because they are never used in math and can have leading zeros or formatting characters that a numeric column would break.

location_code is used directly as StorageLocation's primary key instead of adding a separate surrogate id, since it is already short and unique ("Shelf A3").

Borrowing.return_date is DATE and left nullable with no default, because a tool currently on loan simply has no return date yet - NULL is the only value that correctly represents that.

-- Task 5: Debugging the Cross-Week Mismatch

The broken query was:

SELECT borrow_date, return_date
FROM borrowing
WHERE member_name = 'Son Guko';
Why it fails

Borrowing does not have a member_name column. A member's name only lives in the Member table; Borrowing only stores member_id, a foreign key pointing back to Member. This is a normalization decision from Week 3 - repeating a member's name in every borrowing row would duplicate data and risk it going out of sync if a name were ever corrected. Week 4's DDL enforces this: Borrowing was never given a member_name column, so MySQL rejects the query with "Unknown column 'member_name' in 'where clause'." It is not that the query returns zero rows - the column simply does not exist.

Corrected queries
-- Step 1: find the member's id
SELECT member_id
FROM Member
WHERE name = 'Son Guko';
-- returns member_id = 1

-- Step 2: use that id to filter Borrowing
SELECT borrow_date, return_date
FROM Borrowing
WHERE member_id = 1;

Result of Step 2:

borrow_date	return_date
2025-01-05	2025-01-10
2025-03-02	NULL
What this illustrates

This is a Week 5 concept at its core - a WHERE clause can only filter columns that exist in the table named in FROM, so when the value you need is in a different table, you need a lookup query first. But the root cause goes back further: it is also a Week 3 concept (the normalized design that keeps name only in Member) and a Week 4 concept (the DDL that physically enforces that, so there is no member_name column to reference in the first place).

-- Task 6: Video Walkthrough

Recorded separately and uploaded to YouTube as unlisted, walking through the conceptual ERD, the logical ERD and schema, the live database with DESCRIBE verification, all five Task 4 queries, and the Task 5 broken vs. corrected queries.