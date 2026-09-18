-- Task 3: MySQL DDL Implementation
-- Database: toolshare_prelim

CREATE DATABASE toolshare_prelim;
USE toolshare_prelim;

--Member
CREATE TABLE Member (
    member_id INT Auto_increment PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    membership_start_date DATE NOT NULL,
);

--StoragLocation
CREATE TABLE StorageLocation (
    location_code VARCHAR(10) PRIMARY KEY,
    description VARCHAR(255),
);

--Certification
CREATE TABLE Certification (
    cert_id INT Auto_increment PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
);

--Tool (depends on StorageLocation)
CREATE TABLE Tool (
    tool_id INT Auto_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    location_code VARCHAR(10) NOT NULL,
    Constraint fk_tool_location
        FOREIGN KEY (location_code) REFERENCES StorageLocation(location_code
);

-- Borrowing (depends on Member + Tool)
CREATE TABLE Borrowing(
    borrowing_id INT Auto_increment PRIMARY KEY,
    member_id INT NOT NULL,
    tool_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE NULL,
    Constraint fk_borrowing_member
        FOREIGN KEY (member_id) REFERENCES Member(member_id),
    Constraint fk_borrowing_tool
        FOREIGN KEY (tool_id) REFERENCES Tool(tool_id)
);

--ToolCertification (depends on Tool + Certification)
CREATE TABLE ToolCertification (
    tool_id INT NOT NULL,
    cert_id INT NOT NULL,
    PRIMARY KEY (tool_id, cert_id),
    Constraint fk_toolcert_tool
        FOREIGN KEY (tool_id) REFERENCES Tool(tool_id),
    Constraint fk_toolcert_cert
        FOREIGN KEY (cert_id) REFERENCES Certification(cert_id)
);

--MemberCertification (depends on Member + Certification)
CREATE TABLE MemberCertification (
    member_id INT NOT NULL,
    cert_id INT NOT NULL,
    completion_date DATE NOT NULL,
    PRIMARY KEY (member_id, cert_id),
    Constraint fk_membercert_member
        FOREIGN KEY (member_id) REFERENCES Member(member_id),
    Constraint fk_membercert_cert
        FOREIGN KEY (cert_id) REFERENCES Certification(cert_id)
);

-- Verifation
SHOW TABLES;
DESCRIBE Member;
DESCRIBE StorageLocation;
DESCRIBE Certification;
DESCRIBE Tool;
DESCRIBE Borrowing;
DESCRIBE ToolCertification;
DESCRIBE MemberCertification;