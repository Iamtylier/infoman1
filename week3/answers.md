* **INFORMAN1 LAB: LOGICAL ERD MODELING 2**

**TASK 1**  
The owner’s full name is a composite attribute because it can be divided into first name and last name.

The veterinarian’s full name can also be divided into first name and last name.

**Multivalued Attribute**

Vaccination history is multivalued because one pet can have zero, one, or many vaccination records. It is represented by a separate entity called vaccination\_record.

**Derived Attribute**

Age can be a derived attribute if it is calculated from a pet’s birth date. However, the case study only gives the pet’s age and does not give a birth date. Therefore, age is stored as a normal attribute in this lab.

**Weak Entity**

Vaccination Record is a weak entity because it cannot be uniquely identified by itself. It depends on a specific pet.

**Its identifying information is:**

* pet\_id — parent entity key  
* vaccine \_name — partial key  
* vaccination\_date — part of identifying key

The composite primary key is pet\_id \+ vaccine\_name \+ vaccination\_date.

This follows the ERD rule that a weak entity depends on an owner entity for identification.

**TASK 2**  
**1\. Owner — Pet**

* Owner side: one, mandatory  
* Pet side: many, optional

Relationship: An owner may have zero or many pets, but every pet must belong to exactly one owner.

**2\. Pet — Appointment**

* Pet side: one, mandatory  
* Appointment’s side: many, optional

Relationship: A pet may have zero or many appointments, but every appointment must specify exactly one pet.

**3\. Veterinarian — Appointment**

* Veterinarian side: one. mandatory  
* Appointment side: many, optional

Relationship: A veterinarian may conduct zero or many appointments, but every appointment must specify exactly one veterinarian.

**4\. Pet — Vaccination Record**

* Pet side: one, mandatory  
* Vaccination Record: many, optional

Relationship: A pet may have zero or many vaccination records, but every vaccination record must belong to exactly one pet.

**TASK 4**

1. **Owner**

	Owner(owner\_id, first\_name, last\_name, phone\_number)  
	Primary key: owner\_id

2. **Pet**  
   Pet(pet\_id, name, species, age, owner,\_id)  
   Primary key: pet\_id  
   Foreign key: owner\_id  
     
3. **Veterinarian**  
   Veterinarian(vet\_id, first\_name, last\_name, specialization)  
   Primary key: vet\_id

4. **Appointment**  
   Appointment(appointment\_id, appointment date, reason\_for\_visit, pet\_id, vet\_id)  
   Primary key: appointment\_id  
   Foreign keys: pet\_id

		         vet\_id

5. **Vaccination\_Record**  
   Vaccination\_Record(pet\_id, vaccine\_name, vaccination\_date)  
   Composite primary key:  
* pet\_id  
* vaccine\_name  
* vaccination\_date

	Primary key:pet\_id, vaccine\_name, vaccination\_date  
	Foreign key: pet\_id

**TASK 5 — Key Justification and Schema Validation**

#### **A. Key Justification**

**1\. Owner — Surrogate Key**

I chose **`owner_id`** as a surrogate key because it is a unique ID for every owner. Names and phone numbers may not be unique and may change. Using an ID makes it easier to identify each owner.

**2\. Pet — Surrogate Key**

I chose **`pet_id`** as a surrogate key because every pet needs its own unique ID. Pet names can be the same, so the name should not be used as the primary key.

**3\. Vaccination\_Record — Composite Key**

I used a composite key made of **`pet_id`, `vaccine_name`,** and **`vaccination_date`.** The vaccination record depends on a specific pet, and this combination identifies the record.

**B. Schema Validation**

| Scenario requirement | Schema representation |
| :---- | :---- |
| Owner has an owner ID, first name, last name, and phone number. | Owner table contains these attributes. |
| An owner may have zero or many pets. | Pet table has **`owner_id`** as a foreign key. |
| Every pet belongs to exactly one owner. | Pet requires **`owner_id`.** |
| Pet has ID, name, species, and age. | Pet table contains all four attributes. |
| Appointment has ID, date, and reason. | Appointment table contains these attributes. |
| Every appointment has exactly one pet. | Appointment has **`pet_id`** as a foreign key. |
| Every appointment has exactly one veterinarian. | Appointment has **`vet_id`** as a foreign key. |
| A veterinarian may have many appointments or none. | Appointment connects to Veterinarian. |
| A pet may have zero, one, or many vaccination records. | Vaccination\_Record allows many records for one pet. |
| A vaccination record depends on a specific pet. | **`pet_id`** is part of its composite primary key. |
| Relationships must use Crow's Foot notation. | The ERD uses Crow's Foot symbols on all relationships. |

#### **Conclusion**

I learned how to convert a conceptual ERD into a logical ERD and relational schema. I also learned how to identify weak entities, composite attributes, primary keys, and foreign keys. The most challenging part was the vaccination record because it depends on a pet. I solved it by using **`pet_id`, `vaccine_name`**, and **`vaccination_date`** as its composite primary key.

