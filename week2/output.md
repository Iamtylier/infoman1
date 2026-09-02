# **INFOMAN1 – Week 2 Lab: Conceptual ERD Case Study**

**Name:** Bahron Tylier Dolipas  
**Student ID:** 3102473  
**Section:** SNIN1-2

## **Task 1 — Candidate Entities**

| Entity | Justification |
| ----- | ----- |
| Customer | The scenario says that the shop has many customers and each customer can bring one or more cars, so Customer is a separate entity. |
| Car | The scenario says that each car has a model, plate number, and color and belongs to exactly one customer, so the car is a separate entity. |
| Mechanic | The scenario says that the shop employs several mechanics and each mechanic has a name and specialty, so Mechanic is a separate entity. |
| Service Appointment | The scenario says that a mechanic works on a car during a scheduled service appointment and each appointment has a date and repair note, so Service Appointment is a separate entity. |

## **Task 2 — Attributes per Entity**

### **Customer**

* **Primary Key:** customer\_id  
* **Attributes:**  
  * customer\_id — 1248  
  * customer\_name — Spongebob  
  * contact\_number — 09020202022

### **Car**

* **Primary Key:** car\_id  
* **Attributes:**  
  * car\_id — 1632  
  * model — Toyota Land Cruiser  
  * plate\_number — ABC1234  
  * color — White,Gold

### **Mechanic**

* **Primary Key:** mechanic\_id  
* **Attributes:**  
  * mechanic\_id — 002  
  * mechanic\_name — Peter Parker  
  * specialty — Engine

### **Service Appointment**

* **Primary Key:** appointment\_id  
* **Attributes:**  
  * appointment\_id — 003  
  * appointment\_date — September 27, 3023  
  * repair\_note — Oil Change and Engine Maintenance

## **Task 3 — Relationships**

| Relationship (verb phrase) | Between | Cardinality | Checked both directions? |
| ----- | ----- | ----- | ----- |
| Owns | Customer ↔ Car | 1 | Yes — one customer may own many cars, but each car belongs to exactly one customer. |
| Has | Car ↔ Service Appointment | 1 | Yes — one car may have many service appointments over time, but each service appointment is for one car. |
| Works on | Mechanic ↔ Service Appointment | 1 | Yes — one mechanic may work on many service appointments, but each service appointment has one mechanic. |

## 

## 

## 

## **Task 4 — Conceptual ERD**

The ERD shows the four entities, their attributes, primary keys, relationships, and cardinality markers.

