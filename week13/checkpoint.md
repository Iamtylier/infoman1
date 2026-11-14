# INFOMAN1 Week 13 — F1 Checkpoint

**Student:** Tylier Dolipas  
**Project:** Campus Library Loan System (INFOMAN1 only)  
**Repository:** https://github.com/lamtylier/infoman1

## 1. Where things are

| Item | Location |
|---|---|
| Schema, seed data, views | `infoman1/week13/` (`schema.sql`, `seed.sql`, `views.sql`) |
| Rejected-input tests | `infoman1/week13/evidence_tests.sql` (run in a test database) |
| ERD | `infoman1/week13/erd.mermaid` |
| Application (Spring Boot, Java) | `infoman1/app/` on branch `main` |
| Evidence screenshots and output | `infoman1/week13/evidence/` |

## 2. Environment

| Item | Value |
|---|---|
| MySQL server | 8.0.46 (from `SELECT VERSION();`), InnoDB |
| MySQL port on my machine | 3307 (the default is 3306) |
| Java | JDK 25.0.4 |
| Spring Boot | 4.1.2 (Maven wrapper in `app/`) |
| Databases | `campus_library` (real), `campus_library_test` (disposable tests) |

## 3. Execution order

1. Create the database: `CREATE DATABASE campus_library;`
2. Run `week13/schema.sql`, then `week13/seed.sql`, then `week13/views.sql` (in that order, inside `campus_library`).
3. Create a limited account for the app:
   `CREATE USER 'library_app'@'localhost' IDENTIFIED BY '<your-password>';`
   `GRANT SELECT, INSERT, UPDATE, DELETE ON campus_library.* TO 'library_app'@'localhost';`
4. In the `app/` folder, set the environment variables (below), then run `./mvnw spring-boot:run`.
5. Open `http://localhost:8080/api/books` and `http://localhost:8080/`.
6. For the rejected-input tests, create `campus_library_test`, load the same three files into it, then run `evidence_tests.sql` one statement at a time.

## 4. Configuration variable names

The app reads its connection settings from environment variables. No password is stored in any file in the repository.

| Variable | Meaning | Default in `application.properties` |
|---|---|---|
| `DB_HOST` | MySQL host | `localhost` (I use `127.0.0.1`) |
| `DB_PORT` | MySQL port | `3306` (I use `3307`) |
| `DB_NAME` | Database name | `campus_library` |
| `DB_USER` | App account name | none |
| `DB_PASSWORD` | App account password | none |

## 5. Requirement → feature/file → test/evidence

| # | Requirement | Feature / file | Test / evidence | F1 status |
|---|---|---|---|---|
| R1 | A librarian can add a book with a category | `book.category_id` (NOT NULL, FK), `seed.sql` | `06_show_create_book.png`, `03_counts.png` | Table and data done; adding through the app comes in F2 |
| R2 | A librarian can register a member; emails are unique | `member.email` UNIQUE, `seed.sql` | `SHOW CREATE TABLE member` (add screenshot) | Table and data done; registering through the app comes in F2 |
| R3 | Books are listed with category and availability | View `book_availability`, `GET /api/books`, `index.html` | `05_book_availability.png`, `11_app_matches_sql.png`, `12_api_books.json` | Working |
| R4 | Loans are listed with member name and book title | View `loan_details` | `04_loan_details.png` | View working; showing it in the app comes later |
| R5 | Available copies stay between 0 and the total | `chk_book_available`, `chk_book_total` | `06_show_create_book.png`, `09_test_check_rule.png` | Working |
| R6 | A loan cannot point to a missing book or member | `fk_loan_book`, `fk_loan_member`, `fk_book_category` | `08_test_invalid_fk.png`, `SHOW CREATE TABLE loan` (add screenshot) | Working |

## 6. Expected versus actual results

| Test | Input | Expected | Actual |
|---|---|---|---|
| Duplicate unique value | `INSERT INTO category (name) VALUES ('Computing');` | `ERROR 1062` | `ERROR 1062 ... Duplicate entry 'Computing' for key 'category.name'` |
| Invalid foreign key | book with `category_id = 999` | `ERROR 1452` | `ERROR 1452 ... foreign key constraint fails (campus_library_test.book ...)` |
| CHECK rule | `total_copies = 1`, `available_copies = 5` | `ERROR 3819` | `ERROR 3819 ... Check constraint 'chk_book_available' is violated.` |
| View shows live data | rename member 1 in the test database | view shows the new name | `Maria Santos` changed to `Maria S. Santos` without recreating the view |
| App read | `GET /api/books` | the same 5 rows as `book_availability` | 5 rows, matching titles and copy counts |

## 7. Problem diagnosed

The app failed to start with `Connection refused`, followed by a Hibernate message "Unable to determine Dialect". The second message was only a side effect, because Hibernate cannot ask MySQL anything without a connection. My MySQL server listens on port 3307, but the app used the default 3306. I fixed it by setting `DB_PORT=3307` and `DB_HOST=127.0.0.1` as environment variables, without changing any file.

## 8. Known issues

- Only one read endpoint (`GET /api/books`) exists. Loans, members and write operations come in F2.
- `schema.sql` owns the database structure. JPA is set to `ddl-auto=none`, so it never creates or changes tables.
- The app account has SELECT, INSERT, UPDATE and DELETE only. The formal permission work is Week 15.
- The application has only been run on my own machine.

## 9. Change log

| Date | Change |
|---|---|
| 12 Nov 2026 | Chose the project (started from scratch) and designed the schema |
| 13 Nov 2026 | Created `campus_library`, loaded schema, seed and views, and verified them |
| 13 Nov 2026 | Ran the rejected-input tests in `campus_library_test` |
| 14 Nov 2026 | Generated the Spring Boot project, connected it to MySQL and fixed the port issue |
| 14 Nov 2026 | Captured evidence that the app output matches the SQL result |# INFOMAN1 Week 13 — F1 Checkpoint

**Student:** Tylier Dolipas  
**Project:** Campus Library Loan System (INFOMAN1 only)  
**Repository:** https://github.com/lamtylier/infoman1

## 1. Where things are

| Item | Location |
|---|---|
| Schema, seed data, views | `infoman1/week13/` (`schema.sql`, `seed.sql`, `views.sql`) |
| Rejected-input tests | `infoman1/week13/evidence_tests.sql` (run in a test database) |
| ERD | `infoman1/week13/erd.mermaid` |
| Application (Spring Boot, Java) | `infoman1/app/` on branch `main` |
| Evidence screenshots and output | `infoman1/week13/evidence/` |

## 2. Environment

| Item | Value |
|---|---|
| MySQL server | 8.0.46 (from `SELECT VERSION();`), InnoDB |
| MySQL port on my machine | 3307 (the default is 3306) |
| Java | JDK 25.0.4 |
| Spring Boot | 4.1.2 (Maven wrapper in `app/`) |
| Databases | `campus_library` (real), `campus_library_test` (disposable tests) |

## 3. Execution order

1. Create the database: `CREATE DATABASE campus_library;`
2. Run `week13/schema.sql`, then `week13/seed.sql`, then `week13/views.sql` (in that order, inside `campus_library`).
3. Create a limited account for the app:
   `CREATE USER 'library_app'@'localhost' IDENTIFIED BY '<your-password>';`
   `GRANT SELECT, INSERT, UPDATE, DELETE ON campus_library.* TO 'library_app'@'localhost';`
4. In the `app/` folder, set the environment variables (below), then run `./mvnw spring-boot:run`.
5. Open `http://localhost:8080/api/books` and `http://localhost:8080/`.
6. For the rejected-input tests, create `campus_library_test`, load the same three files into it, then run `evidence_tests.sql` one statement at a time.

## 4. Configuration variable names

The app reads its connection settings from environment variables. No password is stored in any file in the repository.

| Variable | Meaning | Default in `application.properties` |
|---|---|---|
| `DB_HOST` | MySQL host | `localhost` (I use `127.0.0.1`) |
| `DB_PORT` | MySQL port | `3306` (I use `3307`) |
| `DB_NAME` | Database name | `campus_library` |
| `DB_USER` | App account name | none |
| `DB_PASSWORD` | App account password | none |

## 5. Requirement → feature/file → test/evidence

| # | Requirement | Feature / file | Test / evidence | F1 status |
|---|---|---|---|---|
| R1 | A librarian can add a book with a category | `book.category_id` (NOT NULL, FK), `seed.sql` | `06_show_create_book.png`, `03_counts.png` | Table and data done; adding through the app comes in F2 |
| R2 | A librarian can register a member; emails are unique | `member.email` UNIQUE, `seed.sql` | `SHOW CREATE TABLE member` (add screenshot) | Table and data done; registering through the app comes in F2 |
| R3 | Books are listed with category and availability | View `book_availability`, `GET /api/books`, `index.html` | `05_book_availability.png`, `11_app_matches_sql.png`, `12_api_books.json` | Working |
| R4 | Loans are listed with member name and book title | View `loan_details` | `04_loan_details.png` | View working; showing it in the app comes later |
| R5 | Available copies stay between 0 and the total | `chk_book_available`, `chk_book_total` | `06_show_create_book.png`, `09_test_check_rule.png` | Working |
| R6 | A loan cannot point to a missing book or member | `fk_loan_book`, `fk_loan_member`, `fk_book_category` | `08_test_invalid_fk.png`, `SHOW CREATE TABLE loan` (add screenshot) | Working |

## 6. Expected versus actual results

| Test | Input | Expected | Actual |
|---|---|---|---|
| Duplicate unique value | `INSERT INTO category (name) VALUES ('Computing');` | `ERROR 1062` | `ERROR 1062 ... Duplicate entry 'Computing' for key 'category.name'` |
| Invalid foreign key | book with `category_id = 999` | `ERROR 1452` | `ERROR 1452 ... foreign key constraint fails (campus_library_test.book ...)` |
| CHECK rule | `total_copies = 1`, `available_copies = 5` | `ERROR 3819` | `ERROR 3819 ... Check constraint 'chk_book_available' is violated.` |
| View shows live data | rename member 1 in the test database | view shows the new name | `Maria Santos` changed to `Maria S. Santos` without recreating the view |
| App read | `GET /api/books` | the same 5 rows as `book_availability` | 5 rows, matching titles and copy counts |

## 7. Problem diagnosed

The app failed to start with `Connection refused`, followed by a Hibernate message "Unable to determine Dialect". The second message was only a side effect, because Hibernate cannot ask MySQL anything without a connection. My MySQL server listens on port 3307, but the app used the default 3306. I fixed it by setting `DB_PORT=3307` and `DB_HOST=127.0.0.1` as environment variables, without changing any file.

## 8. Known issues

- Only one read endpoint (`GET /api/books`) exists. Loans, members and write operations come in F2.
- `schema.sql` owns the database structure. JPA is set to `ddl-auto=none`, so it never creates or changes tables.
- The app account has SELECT, INSERT, UPDATE and DELETE only. The formal permission work is Week 15.
- The application has only been run on my own machine.

## 9. Change log

| Date | Change |
|---|---|
| 12 Nov 2026 | Chose the project (started from scratch) and designed the schema |
| 13 Nov 2026 | Created `campus_library`, loaded schema, seed and views, and verified them |
| 13 Nov 2026 | Ran the rejected-input tests in `campus_library_test` |
| 14 Nov 2026 | Generated the Spring Boot project, connected it to MySQL and fixed the port issue |
| 14 Nov 2026 | Captured evidence that the app output matches the SQL result |