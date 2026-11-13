-- Campus Library Loan System: schema (MySQL 8.0.16+, InnoDB)
-- Run inside an existing, empty database. Parent tables first.

CREATE TABLE category (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE member (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  joined_on DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE book (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  category_id BIGINT NOT NULL,
  title VARCHAR(150) NOT NULL,
  author VARCHAR(100) NOT NULL,
  isbn VARCHAR(20) NOT NULL UNIQUE,
  total_copies INT NOT NULL DEFAULT 1,
  available_copies INT NOT NULL DEFAULT 1,
  CONSTRAINT fk_book_category FOREIGN KEY (category_id) REFERENCES category(id),
  CONSTRAINT chk_book_total CHECK (total_copies >= 0),
  CONSTRAINT chk_book_available CHECK (available_copies >= 0 AND available_copies <= total_copies)
) ENGINE=InnoDB;

CREATE TABLE loan (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  book_id BIGINT NOT NULL,
  member_id BIGINT NOT NULL,
  loaned_on DATE NOT NULL,
  due_on DATE NOT NULL,
  returned_on DATE NULL,
  CONSTRAINT fk_loan_book FOREIGN KEY (book_id) REFERENCES book(id),
  CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES member(id),
  CONSTRAINT chk_loan_due CHECK (due_on >= loaned_on),
  CONSTRAINT chk_loan_returned CHECK (returned_on IS NULL OR returned_on >= loaned_on)
) ENGINE=InnoDB;
