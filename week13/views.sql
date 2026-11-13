-- Join-based views. Run after schema.sql and seed.sql.

CREATE OR REPLACE VIEW loan_details AS
SELECT l.id          AS loan_id,
       m.full_name   AS member_name,
       b.title       AS book_title,
       c.name        AS category_name,
       l.loaned_on,
       l.due_on,
       l.returned_on,
       CASE WHEN l.returned_on IS NULL THEN 'ON LOAN' ELSE 'RETURNED' END AS loan_status
FROM loan l
JOIN member m   ON m.id = l.member_id
JOIN book b     ON b.id = l.book_id
JOIN category c ON c.id = b.category_id;

CREATE OR REPLACE VIEW book_availability AS
SELECT b.id AS book_id,
       b.title,
       b.author,
       c.name AS category_name,
       b.total_copies,
       b.available_copies
FROM book b
JOIN category c ON c.id = b.category_id;