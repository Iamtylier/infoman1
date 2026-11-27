# INFOMAN1 Week 15 — F3 Lecture Document

**Student:** Tylier Dolipas  
**Project:** Campus Library Loan System (individual work)

## 1. Who is who

| Identity | What it is | Used for |
|---|---|---|
| People using the library page | End users of the application | They are not MySQL accounts |
| `library_app`@`localhost` | The runtime account used by the Spring Boot backend | Everyday reads and writes |
| `library_report`@`localhost` | A read-only reporting account | Reading one approved view |
| `root`@`localhost` | The maintainer / administrator | Creating the schema and managing accounts. It is never used by the app |

Many people can use the page, but the backend always connects to MySQL with one identity, `library_app`. Application rules decide what a person may do. MySQL privileges decide what SQL the backend connection is allowed to run. Both layers matter, because a disabled Delete button does not stop someone who sends their own request or SQL.

## 2. Permission matrix

| Object | `library_app` | `library_report` | `root` |
|---|---|---|---|
| `category` | SELECT | none | all |
| `book` | SELECT, INSERT, UPDATE, DELETE | none | all |
| `member` | SELECT, INSERT, UPDATE, DELETE | none | all |
| `loan` | SELECT, INSERT | none | all |
| view `book_availability` | none | SELECT | all |
| CREATE, ALTER, DROP | none | none | yes |

## 3. Why these grants (least privilege)

The app only needs what its code does. It reads categories but never changes them, so `category` is SELECT only. It adds, edits and deletes books and members, so those get all four. Borrowing adds a loan, and the code never updates or deletes a loan, so `loan` is SELECT and INSERT only. If I add a "return a book" feature later, `loan` will need UPDATE, and I will add only that one privilege then.

The report account can read only `book_availability`. It cannot see the base tables, ISBNs or member data.

Both accounts are limited to `localhost`. In MySQL, `'library_app'@'localhost'` and `'library_app'@'%'` are two different accounts, and the `%` one would accept connections from any computer. Since the database runs on my own machine, `localhost` is enough.

## 4. GRANT, REVOKE and effective permissions

I tested what each account can really do from sessions I identified with `SELECT USER(), CURRENT_USER();`:

- As `library_report`, `SELECT * FROM book_availability` returned 5 rows. `SELECT * FROM book` and `INSERT INTO category` were both denied with `ERROR 1142`.
- As `library_app`, `CREATE TABLE denied_test` in a disposable test database was denied with `ERROR 1142`, and `SHOW TABLES` there was empty.
- I ran `REVOKE SELECT ON campus_library.book_availability FROM 'library_report'@'localhost'`. Then the same read that worked before was denied with `ERROR 1142`, and `SHOW GRANTS` showed only `USAGE`.
- I restored only that one grant. The report user could read the view again.

`REVOKE` removes only the grant it names. If the account had received the same permission from a broader grant or a role, the read would still have worked, so when a result surprises me I check `SHOW GRANTS` first. Here there was no other grant, so the revoke changed the result.

## 5. View security

`SHOW CREATE VIEW book_availability` shows `DEFINER=root@localhost` and `SQL SECURITY DEFINER`. With definer security, the view runs with its creator's rights, so `library_report` can read it without any privilege on `book` or `category`. That is why the read worked while `SELECT * FROM book` was denied. The view only exposes the book id, title, author, category name and copy counts.

With invoker security, `library_report` would also need SELECT on `book` and `category`, which defeats the purpose. I chose definer for that reason. A view is not a security boundary by itself, though. If I had also given the report account SELECT on all the base tables, the view would restrict nothing.

## 6. Who owns the schema

The maintainer (root) creates and changes tables with `week13/schema.sql`. The app account has no CREATE, ALTER or DROP, which I proved with the denied `CREATE TABLE`. In `application.properties` I set `spring.jpa.hibernate.ddl-auto=validate`, so Hibernate only checks that the tables match my entity classes and never changes them. The app started normally with `validate` and the restricted account, which shows the schema matches the code without giving the app any schema rights.

## 7. Problems I diagnosed

**The first denial tests ran as root.**
- *Symptom:* The statements that should have been denied all succeeded, and `SELECT USER(), CURRENT_USER(), DATABASE();` showed `root@localhost`. The `INSERT` added a `Denied Test` row to `category`, twice.
- *Cause:* I typed the test statements into the root MySQL window instead of the session logged in as `library_report`. Root can do everything, so the test proved nothing.
- *Fix:* I deleted the two extra rows by id, then reran the test as `library_report` using one PowerShell command (`mysql -u library_report -p -e "..."`) that prints `USER()` first, so the identity is part of the evidence.
- *Lesson:* Always check `USER()` before trusting a denial test.

**The app failed with `Access denied ... (using password: YES)`.**
- *Symptom:* The app crashed on startup, and a direct `mysql` login with the same password also failed with `ERROR 1045`.
- *Cause:* The password in the `DB_PASSWORD` variable was not the one MySQL had for `library_app`. In another terminal the variable was missing entirely (`password NOT set`), because environment variables only last in the terminal where they were set.
- *Fix:* I generated one password, set it on the account from that same value, tested it with a direct `mysql` login, and saved it to a file outside the repository. The app reads it from `DB_PASSWORD`.
- *Order I now check:* server running, host and port reachable (`127.0.0.1`, `3307`), database exists, credentials accepted, tables exist, then the query.

## 8. Secrets

The app reads `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` and `DB_PASSWORD` from environment variables. No password is in the repository, in `access_control.sql` (it only has placeholders), or in the browser code. The browser only calls the backend, and only the backend connects to MySQL. My real passwords are kept in a private file outside the repository.