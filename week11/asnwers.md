# Lab 11: Database Normalization

## Task 1: Diagnose the Anomalies

**(a) Update anomaly**
```sql
SELECT COUNT(*) AS rows_with_D01 FROM student_enrollment WHERE dept_id = 'D01';
SELECT dept_id, department_name FROM student_enrollment WHERE dept_id = 'D01';
```
3 rows carry D01 and its name, so a rename must update all 3, and missing one leaves conflicting names. **Cause:** the department name is stored on every enrollment row.

**(b) Insert anomaly**
```sql
SELECT * FROM student_enrollment WHERE course_id = 'IT103';
SELECT NULL AS student_id, NULL AS student_name, NULL AS enrolled_courses,
       'IT103' AS course_id, 'Intro to Networks' AS course_title,
       'D01' AS dept_id, 'Computing Studies' AS department_name, NULL AS grade;
```
IT103 returns an empty set, and storing it would need NULL or an invented student. **Cause:** course facts and student enrollments share one table.

**(c) Delete anomaly**
```sql
SELECT course_id, course_title, COUNT(*) AS rows_for_course
FROM student_enrollment GROUP BY course_id, course_title;
SELECT * FROM student_enrollment WHERE course_id = 'IT102';
```
IT102 exists in only 1 row (Ana's), so removing it would erase the course Web Development. **Cause:** course facts exist only inside enrollment rows.

---

## Task 2: First Normal Form

```sql
CREATE TABLE enrollment_1nf (
  student_id INT NOT NULL,
  student_name VARCHAR(100),
  course_id VARCHAR(10) NOT NULL,
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100),
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollment_1nf
  (student_id, student_name, course_id, course_title, dept_id, department_name, grade)
SELECT student_id, student_name, course_id, course_title, dept_id, department_name, grade
FROM student_enrollment;

SELECT * FROM enrollment_1nf;
```
I removed the multi-valued cell `enrolled_courses`, since each student-course pair already has its own row (no data lost). The primary key `(student_id, course_id)` identifies each row, and the SELECT shows 3 rows with one value in every cell.

**Leftover redundancy:** Ana's name appears twice, and the course title, `dept_id` and `department_name` repeat across rows. Tasks 3 and 4 remove it.

---

## Task 3: Second Normal Form

**Composite key:** `(student_id, course_id)`

**Dependencies:**
- `student_id -> student_name` (partial)
- `course_id -> course_title, dept_id` (partial)
- `dept_id -> department_name` (transitive, handled in Task 4)
- `(student_id, course_id) -> grade` (full key)

```sql
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses_stage (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10),
  department_name VARCHAR(100)
);

CREATE TABLE enrollments (
  student_id INT NOT NULL,
  course_id VARCHAR(10) NOT NULL,
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id),
  CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_enr_course FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
);
```

**Reconstructing JOIN:**
```sql
SELECT s.student_id, s.student_name, c.course_id, c.course_title,
       c.dept_id, c.department_name, e.grade
FROM enrollments e
INNER JOIN students s      ON e.student_id = s.student_id
INNER JOIN courses_stage c ON e.course_id  = c.course_id
ORDER BY s.student_id, c.course_id;
```
Returns the same 3 rows as the original data.

Why grade stays with the full key: a grade belongs to one student in one specific course, so neither column alone determines it.

---

## Task 4: Third Normal Form

**Transitive chain:** `course_id -> dept_id -> department_name`

```sql
CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);
INSERT INTO departments (dept_id, department_name)
SELECT DISTINCT dept_id, department_name FROM courses_stage;

ALTER TABLE courses_stage
  ADD CONSTRAINT fk_courses_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
ALTER TABLE courses_stage DROP COLUMN department_name;
RENAME TABLE courses_stage TO courses;
```

**Decision path per table:**

| Table | Multi-valued? | Partial? | Transitive? | Verdict |
|---|---|---|---|---|
| students | No | No | No | 3NF |
| departments | No | No | No | 3NF |
| courses | No | No | No (department_name removed) | 3NF |
| enrollments | No | No (grade needs the full key) | No | 3NF |

**Four-table JOIN:**
```sql
SELECT s.student_name, c.course_title, d.department_name, e.grade
FROM enrollments e
INNER JOIN students s    ON e.student_id = s.student_id
INNER JOIN courses c     ON e.course_id  = c.course_id
INNER JOIN departments d ON c.dept_id    = d.dept_id
ORDER BY s.student_id, c.course_id;
```
Returns 3 complete rows: Ana Cruz (Database Systems 1.50, Web Development 1.25) and Ben Lim (Database Systems 1.75), all in Computing Studies.

## Task 5: Reflection

I would normalize the enrollment system to 3NF because it records changing, shared facts, and each fact should live in exactly one place. In Task 1, department D01 and its name were stored on all three rows, so renaming the department meant updating every row, and missing one would leave conflicting names. After splitting out departments, the name exists once.

I would deliberately keep some repetition only in read-only copies, such as a printed transcript or a reporting view, where the course title should stay as it was when the grade was issued.

The mistake I observed was stopping at 1NF. After Task 2, the table had a primary key and atomic cells, so it looked finished, but department_name still repeated on every row. The symptom was that a rename would still need several updates. I fixed it by splitting out students and courses for 2NF, then departments for 3NF, and the four-table JOIN confirmed that no information was lost.