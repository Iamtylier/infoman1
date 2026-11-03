-- Lab 11: Database Normalization
USE infoman1_normalization;

-- ---------- Task 1: Diagnose the anomalies (SELECT only) ----------
-- (a) Update anomaly: how many rows carry D01?
SELECT COUNT(*) AS rows_with_D01 FROM student_enrollment WHERE dept_id = 'D01';
SELECT dept_id, department_name FROM student_enrollment WHERE dept_id = 'D01';

-- (b) Insert anomaly: IT103 has no row, and a new row would need a made-up student
SELECT * FROM student_enrollment WHERE course_id = 'IT103';
SELECT NULL AS student_id, NULL AS student_name, NULL AS enrolled_courses,
       'IT103' AS course_id, 'Intro to Networks' AS course_title,
       'D01' AS dept_id, 'Computing Studies' AS department_name, NULL AS grade;

-- (c) Delete anomaly: IT102 exists in only one row (Ana's)
SELECT course_id, course_title, COUNT(*) AS rows_for_course
FROM student_enrollment
GROUP BY course_id, course_title;
SELECT * FROM student_enrollment WHERE course_id = 'IT102';

-- ---------- Task 2: First normal form ----------
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

-- ---------- Task 3: Second normal form ----------
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);
INSERT INTO students (student_id, student_name)
SELECT DISTINCT student_id, student_name FROM enrollment_1nf;

CREATE TABLE courses_stage (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10),
  department_name VARCHAR(100)
);
INSERT INTO courses_stage (course_id, course_title, dept_id, department_name)
SELECT DISTINCT course_id, course_title, dept_id, department_name FROM enrollment_1nf;

CREATE TABLE enrollments (
  student_id INT NOT NULL,
  course_id VARCHAR(10) NOT NULL,
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id),
  CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_enr_course FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
);
INSERT INTO enrollments (student_id, course_id, grade)
SELECT student_id, course_id, grade FROM enrollment_1nf;

-- the wide report still reconstructs
SELECT s.student_id, s.student_name, c.course_id, c.course_title,
       c.dept_id, c.department_name, e.grade
FROM enrollments e
INNER JOIN students s      ON e.student_id = s.student_id
INNER JOIN courses_stage c ON e.course_id  = c.course_id
ORDER BY s.student_id, c.course_id;

-- ---------- Task 4: Third normal form ----------
CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);
INSERT INTO departments (dept_id, department_name)
SELECT DISTINCT dept_id, department_name FROM courses_stage;

-- reduce the course table to (course_id, course_title, dept_id) with a foreign key
ALTER TABLE courses_stage
  ADD CONSTRAINT fk_courses_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
ALTER TABLE courses_stage DROP COLUMN department_name;
RENAME TABLE courses_stage TO courses;

DESCRIBE departments;
DESCRIBE courses;

-- four-table join that rebuilds the full report
SELECT s.student_name, c.course_title, d.department_name, e.grade
FROM enrollments e
INNER JOIN students s    ON e.student_id = s.student_id
INNER JOIN courses c     ON e.course_id  = c.course_id
INNER JOIN departments d ON c.dept_id    = d.dept_id
ORDER BY s.student_id, c.course_id;