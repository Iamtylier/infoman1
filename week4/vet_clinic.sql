-- Week 4 Lab - Veterinary Clinic Database
-- INFOMAN1

-- Task 1: Create the database
CREATE DATABASE infoman1_vetclinic;
SHOW DATABASES;
USE infoman1_vetclinic;

-- Task 2: Create the core tables
CREATE TABLE owner (
  owner_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  phone_number INT
);

CREATE TABLE veterinarian (
  vet_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  specialization VARCHAR(50)
);

CREATE TABLE pet (
  pet_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  species VARCHAR(30),
  age INT,
  owner_id INT NOT NULL,
  FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

-- Task 3: Create the relationship tables
CREATE TABLE appointment (
  appointment_id INT PRIMARY KEY AUTO_INCREMENT,
  appointment_date DATE NOT NULL,
  reason_for_visit VARCHAR(100),
  pet_id INT NOT NULL,
  vet_id INT NOT NULL,
  FOREIGN KEY (pet_id) REFERENCES pet(pet_id),
  FOREIGN KEY (vet_id) REFERENCES veterinarian(vet_id)
);

CREATE TABLE vaccination_record (
  pet_id INT NOT NULL,
  vaccine_name VARCHAR(50) NOT NULL,
  vaccination_date DATE NOT NULL,
  PRIMARY KEY (pet_id, vaccine_name, vaccination_date),
  FOREIGN KEY (pet_id) REFERENCES pet(pet_id)
);

-- Task 4: Verify the schema
SHOW TABLES;
DESCRIBE owner;
DESCRIBE pet;
DESCRIBE veterinarian;
DESCRIBE appointment;
DESCRIBE vaccination_record;

-- Task 5: Fix the mistake (phone_number was INT, should be text)
DESCRIBE owner;
ALTER TABLE owner MODIFY COLUMN phone_number VARCHAR(20);
DESCRIBE owner;