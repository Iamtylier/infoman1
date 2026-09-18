-- Task 5: Debug a Cross-Week Mismatch

USE toolshare_prelim;

-- Original broken query (fails: Borrowing has no member_name column)
SELECT borrow_date, return_date
FROM borrowing
WHERE member_name = 'Maria Santos';

-- Corrected query, step 1: look up the member's id in the Member table
SELECT member_id
FROM Member
WHERE name = 'Maria Santos';
-- returns member_id = 1

-- Corrected query, step 2: use that id to filter the Borrowing table
SELECT borrow_date, return_date
FROM Borrowing
WHERE member_id = 1;