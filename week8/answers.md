# Week 8 Lab: Employee Payroll Query Lab

## Task 1: Pattern Matching

**1.1** Last names ending in "ez"
```sql
SELECT emp_id, first_name, last_name FROM employee WHERE last_name LIKE '%ez';
```
Rows: **250**

**1.2** First names starting with "Ma"
```sql
SELECT emp_id, first_name, department FROM employee WHERE first_name LIKE 'Ma%';
```
Rows: **167**

**1.3a** All codes are 5 characters starting with E
```sql
SELECT COUNT(*) FROM employee WHERE emp_code LIKE 'E____';
```
Rows: **500** (all rows match)

**1.3b** Third character is 0
```sql
SELECT emp_code, first_name, last_name FROM employee WHERE emp_code LIKE 'E_0__';
```
Rows: **99**

---

## Task 2: Aggregation and NULLs

**2.1**
```sql
SELECT COUNT(*), COUNT(commission) FROM employee;
```
Result: 500 employees, 350 with commission

**2.2**
```sql
SELECT SUM(salary) FROM employee;
```
Result: 31,230,000.00

**2.3**
```sql
SELECT AVG(salary), MIN(hire_date), MAX(hire_date) FROM employee;
```
Result: 62,460 | 2015-01-13 | 2026-03-23

**2.4**
```sql
SELECT SUM(salary + COALESCE(commission, 0)) FROM employee;
```
Result: 32,542,500.00

**Explanation:** COUNT(*) counts every row (500), but COUNT(commission) skips NULLs (350). The gap of 150 is the employees with no commission. In 2.4, salary + NULL gives NULL, so COALESCE(commission, 0) is needed to keep those employees in the total.

---

## Task 3: Grouping

**3.1**
```sql
SELECT department, COUNT(*), AVG(salary), COUNT(DISTINCT job_title)
FROM employee GROUP BY department;
```
| department | headcount | avg_salary | titles |
|---|---|---|---|
| Engineering | 100 | 51,900 | 3 |
| Finance | 100 | 65,500 | 3 |
| HR | 100 | 64,100 | 3 |
| Sales | 100 | 59,100 | 3 |
| Support | 100 | 71,700 | 3 |

**3.2**
```sql
SELECT department, job_title, COUNT(*)
FROM employee GROUP BY department, job_title;
```
Result: 15 rows, each department-title combination has 33 or 34 employees (see screenshot).

---

## Task 4: HAVING

**4.1** Threshold: **65,000**. I chose it because it is above the overall average (62,460) and splits the departments into higher-paid and lower-paid.
```sql
SELECT department, AVG(salary) FROM employee
GROUP BY department HAVING AVG(salary) > 65000;
```
Result: Finance (65,500), Support (71,700)

Why HAVING: AVG(salary) is calculated after grouping, and WHERE runs before grouping.

**4.2**
```sql
SELECT department, COUNT(*) FROM employee
WHERE status = 'Active'
GROUP BY department HAVING COUNT(*) > 50;
```
Result: Sales 100, HR 100, Engineering 100

Why HAVING: WHERE filters rows first, but "more than 50" is a condition on the group's COUNT(*), which only exists after GROUP BY.