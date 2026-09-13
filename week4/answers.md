# **Week 4 Lab Answers**

INFOMAN1 \- DDL & Table Creation

## **Task 1 \- Create the Database**

Ran CREATE DATABASE infoman1\_vetclinic; then checked with SHOW DATABASES; to make sure it was actually there.

Screenshot: screenshots/task1\_show\_databases.png

infoman1\_vetclinic shows up in the list, so the database was created.

## **Task 2 \- Create the Core Tables**

Made owner, veterinarian, and pet based on my Week 3 schema.

* owner(owner\_id, first\_name, last\_name, phone\_number) \- owner\_id is the PK  
* veterinarian(vet\_id, first\_name, last\_name, specialization) \- vet\_id is the PK  
* pet(pet\_id, name, species, age, owner\_id) \- pet\_id is PK, owner\_id is FK to owner

Data types I used:

* owner\_id, pet\_id, vet\_id \= INT AUTO\_INCREMENT (surrogate keys, auto generate)  
* first\_name, last\_name, specialization, species \= VARCHAR since they're just text  
* phone\_number \= started as INT (this was the mistake for Task 5, fixed later)  
* age \= INT since it's a whole number

Screenshot: screenshots/task2\_create\_tables.png

## **Task 3 \- Create the Relationship Tables**

Made an appointment and vaccination\_record next.

* appointment(appointment\_id, appointment\_date, reason\_for\_visit, pet\_id, vet\_id) \- appointment\_id is PK, pet\_id and vet\_id are both FKs  
* vaccination\_record(pet\_id, vaccine\_name, vaccination\_date) \- this is the weak entity from Week 3, so the PK is all three columns together (pet\_id \+ vaccine\_name \+ vaccination\_date), pet\_id is also a FK

Screenshot: screenshots/task3\_create\_tables.png

## **Task 4 \- Verify the Schema**

Ran SHOW TABLES; and all 5 tables showed up (owner, pet, veterinarian, appointment, vaccination\_record).

Screenshot: screenshots/task4\_show\_tables.png

Then ran DESCRIBE on each table to compare against my Week 3 schema:

* owner \- phone\_number showed up as int instead of text, which was wrong (fixed in Task 5 below)  
* pet \- matched, owner\_id shows MUL under Key so the FK worked  
* veterinarian \- matched exactly, no issues  
* appointment \- matched, both pet\_id and vet\_id show MUL so both FKs worked  
* vaccination\_record \- matched, all 3 key columns show PRI which means the composite key worked

Screenshots: screenshots/task4\_describe\_owner.png, task4\_describe\_pet.png, task4\_describe\_veterinarian.png, task4\_describe\_appointment.png, task4\_describe\_vaccination\_record.png

## **Task 5 \- Fix a Deliberate Mistake**

The mistake: I made phone\_number an INT on purpose instead of text.

Why it's a problem: storing a phone number as a number is bad because it can drop leading zeros, and phone numbers aren't actually used for math so there's no reason to store them as a number type. It also can't hold things like dashes or parentheses if the number ever needs that format.

How DESCRIBE showed it: running DESCRIBE owner; before the fix showed phone\_number as int in the Type column, which confirmed the mistake was actually there.

Screenshot (before): screenshots/task5\_describe\_owner\_before.png

The fix: ALTER TABLE owner MODIFY COLUMN phone\_number VARCHAR(20);

After running that, DESCRIBE owner; showed phone\_number as varchar(20) instead, so the fix worked.

Screenshot (after): screenshots/task5\_describe\_owner\_after.png

