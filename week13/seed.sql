-- Fictional seed data. Run after schema.sql. Parent tables first.

INSERT INTO category (name) VALUES
  ('Computing'), ('Fiction'), ('Science'), ('History');

INSERT INTO member (full_name, email, joined_on) VALUES
  ('Maria Santos',   'maria.santos@example.com',   '2026-08-10'),
  ('Juan Dela Cruz', 'juan.delacruz@example.com',  '2026-08-12'),
  ('Ana Reyes',      'ana.reyes@example.com',      '2026-09-01'),
  ('Carlo Mendoza',  'carlo.mendoza@example.com',  '2026-09-05');

INSERT INTO book (category_id, title, author, isbn, total_copies, available_copies) VALUES
  (1, 'Intro to Relational Databases', 'A. Villanueva', '978-1-00000-001-1', 3, 2),
  (1, 'Practical SQL Basics',          'R. Bautista',   '978-1-00000-002-8', 2, 1),
  (2, 'The Island Lantern',            'L. Fernandez',  '978-1-00000-003-5', 2, 2),
  (3, 'Backyard Astronomy',            'M. Torres',     '978-1-00000-004-2', 1, 0),
  (4, 'Stories of the Archipelago',    'J. Ramos',      '978-1-00000-005-9', 2, 2);

-- Active loans (returned_on IS NULL) match the reduced available_copies above.
INSERT INTO loan (book_id, member_id, loaned_on, due_on, returned_on) VALUES
  (1, 1, '2026-11-02', '2026-11-16', NULL),
  (2, 2, '2026-11-03', '2026-11-17', NULL),
  (4, 3, '2026-11-04', '2026-11-18', NULL),
  (3, 1, '2026-10-20', '2026-11-03', '2026-10-30'),
  (1, 4, '2026-10-15', '2026-10-29', '2026-10-28');
  