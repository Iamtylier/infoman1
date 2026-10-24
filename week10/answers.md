# Lab 10: Safe DML & Data Integrity

## Task 1: Safe INSERT

```sql
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');
SELECT * FROM products WHERE sku = 'CALC-SCI-001';

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');
SELECT * FROM products WHERE sku = 'CMP-001';
```
Each SELECT returned 1 row.

**Rejected insert:**
```sql
INSERT INTO sales (product_id, sale_date, quantity) VALUES (999, '2026-08-12', 1);
```
Fails with ERROR 1452 because product 999 does not exist, and `sales.product_id` is a foreign key to `products`.

---

## Task 2: UPDATE & DELETE

**UPDATE (Calculator, product_id 6)**
```sql
SELECT * FROM products WHERE product_id = 6;
UPDATE products SET price = 875.00 WHERE product_id = 6;
SELECT * FROM products WHERE product_id = 6;
```

**DELETE (Eraser, product_id 5)**
```sql
SELECT * FROM products WHERE product_id = 5;
DELETE FROM products WHERE product_id = 5;
SELECT * FROM products WHERE product_id = 5;
```

**Without WHERE:** the UPDATE would change every product's price to 875.00, and the DELETE would try to remove every row.

---

## Task 3: Self Join & Cross Join

**(a)**
```sql
SELECT e.employee_name AS employee, m.employee_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```
3 rows. LEFT JOIN keeps Lea Ramos because her manager_id is NULL (no match), so she shows with a NULL manager.

**(b)**
```sql
SELECT c.color_name, s.size_name FROM colors c CROSS JOIN sizes s;
```
9 rows (3 colors x 3 sizes). A real use is generating every color-and-size variant of a product. It must never happen by accident from a missing ON, because it silently multiplies rows.

---

## Task 4: Constraints

```sql
ALTER TABLE products ADD COLUMN contact_number VARCHAR(20);
```

| Rule | Statement | Valid write | Rejected write |
|---|---|---|---|
| NOT NULL | `ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;` | Stapler | NULL name (ERROR 1048) |
| UNIQUE | `ALTER TABLE products ADD CONSTRAINT uq_products_sku UNIQUE (sku);` | Glue Stick, GL-001 | duplicate GL-001 (ERROR 1062) |
| CHECK | `ALTER TABLE products ADD CONSTRAINT chk_products_price CHECK (price > 0);` | Highlighter, 30.00 | price -5.00 (ERROR 3819) |

**Syntax note:** MySQL has no `ALTER COLUMN ... SET NOT NULL`, so I used `MODIFY`. `CHECK` is enforced from MySQL 8.0.16 on (my server is 8.0.46). I tested each rule with one valid insert and one invalid insert, and `SHOW CREATE TABLE products\G` confirmed all three constraints.

---

## Task 5: Reflection

For a campus bookstore I would use both, but the database should be the last line of defense. Application checks give friendly feedback, such as telling a cashier that a price must be positive, but they can be bypassed by another program, a script or a direct SQL session. Database constraints apply to every writer. In Task 4, the CHECK (price > 0) rule rejected a price of -5.00 with error 3819 no matter how the row was inserted, and the UNIQUE rule on sku blocked a duplicate GL-001.

The mistake I observed is assuming a constraint repairs old data. When I added the CHECK constraint, MySQL reported 8 rows checked. That worked only because every existing price was already positive. If one old row had a bad price, the ALTER TABLE would have failed with an error instead of fixing it. The symptom would be a rejected ALTER statement, and the fix is to find the bad rows first with a SELECT, correct them with a safe UPDATE on product_id, and then add the constraint.