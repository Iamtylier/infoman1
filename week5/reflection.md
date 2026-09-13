# **Week 5 Reflection**

SELECT statements are safe to run freely because a correctly written SELECT only reads data \- it can't change or delete a row no matter how it's written. That's different from DDL, which changes the structure of the database (like DROP TABLE, which permanently deletes a table), and DML, which changes the data inside tables (like DELETE or UPDATE). Since SELECT can't touch either of those, exploring a database with SELECT doesn't carry the same risk that a careless DROP or DELETE would.

For Task 4, the mismatch I introduced was removing the quotes around the string value, changing WHERE species \= 'Dog' to WHERE species \= Dog. The actual effect wasn't zero rows like I expected \- it threw an error instead, something like "Unknown column 'Dog' in 'where clause'". Without quotes, MySQL assumed Dog was a column name instead of a text value, and since no column called Dog exists in the pet table, it couldn't find it.

I diagnosed this by comparing the two queries side by side, noticing the only change was the missing quotes, then reading the error message, which pointed straight to the WHERE clause.

