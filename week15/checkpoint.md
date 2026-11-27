# INFOMAN1 Week 15 — F3 Checkpoint

**Student:** Tylier Dolipas  
**Project:** Campus Library Loan System (INFOMAN1 only)  
**Repository:** https://github.com/lamtylier/infoman1

## 1. Where things are

| Item | Location |
|---|---|
| Account setup template (no real passwords) | `infoman1/week15/access_control.sql` |
| Application (Spring Boot) | `infoman1/app/`, branch `main` |
| Schema, seed and views from F1 | `infoman1/week13/` |
| Transaction scenarios from F2 | `infoman1/week14/` |
| Evidence | `infoman1/week15/evidence/` |

## 2. Environment

| Item | Value |
|---|---|
| MySQL server | 8.0.46 on `127.0.0.1`, port **3307** |
| Java / Spring Boot | JDK 25, Spring Boot 4.1.2 |
| Accounts | `library_app`@`localhost`, `library_report`@`localhost`, `root`@`localhost` |
| Test databases | `campus_library_priv_test` (denied-DDL test), plus earlier test databases |

## 3. Prerequisites and execution order

1. `week13/schema.sql`, `seed.sql` and `views.sql` already run in `campus_library` (as root).
2. Run the parts of `week15/access_control.sql` as root: create the accounts, tighten `library_app`, grant the report account its one view, and create `campus_library_priv_test`.
3. Real passwords are generated locally and typed or loaded at run time. They are never in a file in the repository.
4. Start the app (below), then run the denial and revoke tests as each identity.

## 4. Runtime configuration

| Variable | Meaning |
|---|---|
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `3307` |
| `DB_NAME` | `campus_library` (default) |
| `DB_USER` | `library_app` |
| `DB_PASSWORD` | Loaded from a private file outside the repository |

`application.properties` uses `spring.jpa.hibernate.ddl-auto=validate`. The app never creates or alters tables.

## 5. Schema and migration ownership

The maintainer (root) owns the schema and runs `week13/schema.sql`. The runtime account has no CREATE, ALTER or DROP, and there is no separate migration process yet.

## 6. Evidence: allowed and denied operations

| # | Identity | Input | Expected | Actual | Evidence file |
|---|---|---|---|---|---|
| 1 | `library_app` | `SHOW GRANTS` | Table-level grants only | `USAGE`, CRUD on `book` and `member`, SELECT on `category`, SELECT and INSERT on `loan`, CRUD on `campus_library_priv_test` | `01_show_grants_app.png` |
| 2 | `library_report` | `SELECT * FROM campus_library.book_availability` | Allowed | 5 rows | `02_report_allowed.png` |
| 3 | `library_report` | `SELECT * FROM campus_library.book` | Denied | `ERROR 1142 SELECT command denied ... for table 'book'` | `02_report_allowed.png` |
| 4 | `library_report` | `INSERT INTO campus_library.category (name) VALUES ('Denied Test')` | Denied | `ERROR 1142 INSERT command denied ... for table 'category'` | `03_report_insert_denied.png` |
| 5 | `library_app` | `CREATE TABLE campus_library_priv_test.denied_test (id INT)` | Denied | `ERROR 1142 CREATE command denied ... for table 'denied_test'` | `04_app_ddl_denied.png` |
| 6 | root | `SHOW TABLES FROM campus_library_priv_test` | Empty | Empty set | `05_priv_test_empty.png` |
| 7 | root | `REVOKE SELECT ON campus_library.book_availability FROM 'library_report'@'localhost'` | Grant removed | `SHOW GRANTS` shows only `USAGE` | `06_grants_after_revoke.png` |
| 8 | `library_report` | `SELECT * FROM campus_library.book_availability` | Denied | `ERROR 1142 SELECT command denied ... for table 'book_availability'` | `07_report_denied_after_revoke.png` |
| 9 | root | `GRANT SELECT ON campus_library.book_availability TO 'library_report'@'localhost'` | Grant restored | `SHOW GRANTS` shows `USAGE` and the SELECT | `08_grants_after_restore.png` |
| 10 | `library_report` | `SELECT * FROM campus_library.book_availability` | Allowed again | 5 rows | `09_report_works_after_restore.png` |
| 11 | `library_app` (the application) | Start the app, then add, edit and delete a book, add and delete a member, and borrow a book | All succeed without root | Started with `validate`; CRUD results to be confirmed | `10_app_runs_as_library_app.png`, `11_app_crud_after.png`, `12_app_started.png` |

## 7. Known issues

- `library_app` has no UPDATE or DELETE on `loan`, because returning a book is not implemented yet. It will need UPDATE when that feature is added.
- The F2 demo hook (`simulateFailure`) is still in `BorrowService` and should be removed or disabled before the final release.
- There is only one report view and one report account.
- The first denial tests ran as root by mistake. I deleted the extra `Denied Test` rows and reran them correctly (see `lecture.md`).
- The application has only been run on my own machine.

## 8. Change log

| Date | Change |
|---|---|
| 25 Nov 2026 | Created `library_report`, tightened `library_app` and created the priv-test database |
| 25 Nov 2026 | Ran the report and runtime denial tests, then the revoke and restore tests |
| 27 Nov 2026 | Fixed the password mismatch and started the app as `library_app` with `ddl-auto=validate` |



