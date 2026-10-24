-- Lab 10: Safe DML & Data Integrity
USE infoman1_bookstore;

-- ---------- Task 1: Safe INSERT ----------
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');
SELECT * FROM products WHERE sku = 'CALC-SCI-001';

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');
SELECT * FROM products WHERE sku = 'CMP-001';

-- Rejected insert: product_id 999 does not exist (ERROR 1452)
INSERT INTO sales (product_id, sale_date, quantity)
VALUES (999, '2026-08-12', 1);

-- ---------- Task 2: UPDATE and DELETE ----------
SELECT product_id, product_name, sku, price FROM products;

-- UPDATE: preview, execute, verify
SELECT * FROM products WHERE product_id = 6;
UPDATE products SET price = 875.00 WHERE product_id = 6;
SELECT * FROM products WHERE product_id = 6;

-- DELETE: preview, execute, verify
SELECT * FROM products WHERE product_id = 5;
DELETE FROM products WHERE product_id = 5;
SELECT * FROM products WHERE product_id = 5;

-- ---------- Task 3: Self join and cross join ----------
SELECT e.employee_name AS employee, m.employee_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

SELECT c.color_name, s.size_name
FROM colors c
CROSS JOIN sizes s
ORDER BY c.color_name, s.size_name;

SELECT COUNT(*) AS combinations
FROM colors
CROSS JOIN sizes;

-- ---------- Task 4: Constraints ----------
ALTER TABLE products ADD COLUMN contact_number VARCHAR(20);
DESCRIBE products;

-- NOT NULL
ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Stapler', 'ST-001', 60.00, 40, 'Active');
-- rejected (ERROR 1048)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES (NULL, 'ST-002', 60.00, 40, 'Active');

-- UNIQUE
ALTER TABLE products ADD CONSTRAINT uq_products_sku UNIQUE (sku);
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Glue Stick', 'GL-001', 25.00, 60, 'Active');
-- rejected (ERROR 1062)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Duplicate Glue', 'GL-001', 25.00, 60, 'Active');

-- CHECK
ALTER TABLE products ADD CONSTRAINT chk_products_price CHECK (price > 0);
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Highlighter', 'HL-001', 30.00, 70, 'Active');
-- rejected (ERROR 3819)
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Free Pen', 'FP-001', -5.00, 10, 'Active');

-- confirm the constraints
SHOW CREATE TABLE products\G