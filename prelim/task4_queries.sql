-- Task 4: Sample Data Queries

USE toolshare_prelim;

-- 1. Names and categories of all tools in the Power Tools category
SELECT name, category
FROM Tool
WHERE category = 'Power Tools';

-- 2. Members who joined after January 1, 2025
SELECT member_id, name, membership_start_date
FROM Member
WHERE membership_start_date > '2025-01-01';

-- 3. Borrowing records currently on loan (return_date is NULL)
SELECT borrowing_id, member_id, tool_id, borrow_date, return_date
FROM Borrowing
WHERE return_date IS NULL;

-- 4. All borrowing records for one specific member (Maria Santos, member_id 1)
SELECT borrowing_id, tool_id, borrow_date, return_date
FROM Borrowing
WHERE member_id = 1;

-- 5. Tools purchased before January 1, 2024
SELECT name, purchase_date
FROM Tool
WHERE purchase_date < '2024-01-01';

