# Lab 9: Multi-Table Join Practical Test

> **Note:** The sample students (Ana, Ben, Cara, Dan) were replaced with Tylier Dolipas, Kobe Bryant, Lebron James and Michael Jordan. Ana = Tylier Dolipas, Dan = Michael Jordan.

## Task 1: INNER JOIN

```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
ORDER BY o.order_id;
```
Rows: **3** (Tylier Dolipas 101 and 102, Michael Jordan 103). Only students with orders appear.

---

## Task 2: Missing Relationships

**(a)**
```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
ORDER BY s.student_id, o.order_id;
```
Rows: **5** (Kobe Bryant and Lebron James show NULL).

**(b)**
```sql
SELECT s.student_name, s.program
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_id IS NULL;
```
Rows: **2** (Kobe Bryant, Lebron James). They have no row in `orders`, so their order columns are NULL.

---

## Task 3: Four-Table Report

```sql
SELECT s.student_name, s.program, o.order_id,
       m.item_name, oi.quantity, m.price,
       oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
ORDER BY o.order_id, m.item_name;
```
Rows: **4**. Each JOIN has its own ON key, and columns are qualified with aliases.

---

## Task 4: The Silent Inner Join

**Version 1 (INNER JOIN + date filter): 4 rows**
```sql
SELECT s.student_name AS buyer, m.item_name, oi.quantity * m.price AS line_total
FROM students s
INNER JOIN orders o       ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id   = oi.order_id
INNER JOIN menu_items m   ON oi.menu_id   = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;
```

**Version 2 (LEFT JOIN + WHERE on date): 4 rows**
```sql
SELECT s.student_name AS buyer, m.item_name, oi.quantity * m.price AS line_total
FROM students s
LEFT JOIN orders o       ON s.student_id = o.student_id
LEFT JOIN order_items oi ON o.order_id   = oi.order_id
LEFT JOIN menu_items m   ON oi.menu_id   = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC;
```

**Fix (date moved into ON): 6 rows**
```sql
SELECT s.student_name AS buyer, m.item_name, oi.quantity * m.price AS line_total
FROM students s
LEFT JOIN orders o       ON s.student_id = o.student_id
                        AND o.order_date >= '2026-08-01'
LEFT JOIN order_items oi ON o.order_id   = oi.order_id
LEFT JOIN menu_items m   ON oi.menu_id   = m.menu_id
ORDER BY o.order_date DESC;
```

**Comparison:** The LEFT JOIN without a date filter returns 6 rows. Adding the WHERE on the date drops it to 4, because Kobe Bryant and Lebron James have a NULL `order_date`, and `NULL >= '2026-08-01'` is not true, so WHERE removes them. The LEFT JOIN then acts like an INNER JOIN.

**Fix:** put the date condition in the `ON` clause (or use `WHERE o.order_date >= '2026-08-01' OR o.order_date IS NULL`).

---

## Task 5: Reflection

I would choose INNER JOIN when a report should only include rows that exist on both sides. In Task 1, INNER JOIN between students and orders listed the actual buyers, so Kobe Bryant and Lebron James correctly did not appear. I would choose LEFT JOIN when every row from the main table must be kept even without a match. In Task 2, a LEFT JOIN from students to orders let me find students who never ordered by filtering for o.order_id IS NULL.

The mistake I observed was in Task 4. I started from a LEFT JOIN of students to orders, then added WHERE o.order_date >= '2026-08-01'. The symptom was that the result dropped from 6 rows to 4, and Kobe Bryant and Lebron James disappeared, so the LEFT JOIN behaved like an INNER JOIN. This happened because their order_date is NULL, and a NULL comparison is not true, so WHERE removed them after the join. I fixed it by moving the date condition into the ON clause, which brought the result back to 6 rows.