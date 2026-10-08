USE university_db;
DESCRIBE students;
DESCRIBE instructors;
DESCRIBE courses;
DESCRIBE assignments;

SELECT first_name, last_name, major
FROM students
WHERE major IN = ('Computer Science', 'Information Technology')
    And last_name LIKE 'S%'
    AND not section = 'Online';

SELECT CONCAT(first_name, 1), '. ', last_name, ' ($' , ROUND(salary), ')' AS `Instructor Details`
FROM instructors
LIMIT 5;

SELECT assignment_name,
    DATEDIFF (due_date, assignment_date) AS Days_To_Complete
FROM assignments
WHERE DATEDIFF (due_date, assignment_date) > 14
ORDER BY Days_To_Complete DESC;

SELECT course_code, corse_name, credits
FROM courses
WHERE (course_description IS NULL OR credits BETWEEN 4 and 6)
    AND course_code LIKE '%ADV%'
ORDER BY course_name ASC;

