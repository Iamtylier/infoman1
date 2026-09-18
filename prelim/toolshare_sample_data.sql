-- =====================================================================
-- toolshare_sample_data.sql
-- Sample data for toolshare_prelim (run task3_ddl.sql first)
-- 5 members, 8 tools, 3 storage locations, 4 certifications,
-- 6 borrowing records, plus supporting ToolCertification /
-- MemberCertification rows so the certification rules in the spec are
-- actually exercised.
-- =====================================================================

USE toolshare_prelim;

-- StorageLocation (3)
INSERT INTO StorageLocation (location_code, description) VALUES
('A3', 'Shelf A3, main garage'),
('B1', 'Pegboard B1, south wall'),
('C2', 'Shelf C2, storage room');

-- Certification (4)
INSERT INTO Certification (name) VALUES
('Chainsaw Safety'),
('Welding Basics'),
('Power Tool Handling'),
('Ladder & Height Safety');

-- Member (5)
INSERT INTO Member (name, phone, membership_start_date) VALUES
('Son Guko', '0917-555-0142', '2024-11-03'),
('Roco Tady', '0918-555-0087', '2025-02-14'),
('Hayme Rizal', '0920-555-0199', '2023-08-21'),
('Arki Gladiola', '0999-555-0033', '2025-06-30'),
('Mondragon', '0917-555-0256', '2024-01-10');

-- Tool (8)  -- tool_id 1..8 in this order
INSERT INTO Tool (name, category, purchase_date, location_code) VALUES
('Circular Saw', 'Power Tools', '2023-05-12', 'A3'),
('Chainsaw', 'Power Tools', '2022-09-01', 'A3'),
('Cordless Drill', 'Power Tools', '2024-03-18', 'B1'),
('Welding Machine', 'Power Tools', '2021-11-20', 'C2'),
('Pruning Shears', 'Garden', '2024-07-04', 'B1'),
('Wheelbarrow', 'Garden', '2023-01-15', 'C2'),
('Extension Ladder', 'Ladders', '2022-06-30', 'A3'),
('Hedge Trimmer', 'Garden', '2024-10-09', 'B1');

-- ToolCertification: which tools require which certifications
INSERT INTO ToolCertification (tool_id, cert_id) VALUES
(2, 1),  -- Chainsaw requires Chainsaw Safety
(4, 2),  -- Welding Machine requires Welding Basics
(1, 3),  -- Circular Saw requires Power Tool Handling
(7, 4);  -- Extension Ladder requires Ladder & Height Safety

-- MemberCertification: which members have completed which certifications
INSERT INTO MemberCertification (member_id, cert_id, completion_date) VALUES
(1, 1, '2024-12-01'),  -- Maria Santos - Chainsaw Safety
(1, 3, '2025-01-15'),  -- Maria Santos - Power Tool Handling
(2, 2, '2025-03-01'),  -- Ben Alcantara - Welding Basics
(3, 4, '2023-09-10'),  -- Carla Dizon - Ladder & Height Safety
(5, 3, '2024-02-20');  -- Elena Yu - Power Tool Handling

-- Borrowing (6)
INSERT INTO Borrowing (member_id, tool_id, borrow_date, return_date) VALUES
(1, 2, '2025-01-05', '2025-01-10'),  -- Maria Santos borrowed Chainsaw (returned)
(1, 1, '2025-03-02', NULL),          -- Maria Santos borrowed Circular Saw (on loan)
(2, 4, '2025-03-15', '2025-03-20'),  -- Ben Alcantara borrowed Welding Machine (returned)
(3, 7, '2023-10-01', '2023-10-05'),  -- Carla Dizon borrowed Extension Ladder (returned)
(4, 6, '2025-07-02', '2025-07-04'),  -- Deo Ramirez borrowed Wheelbarrow (returned)
(5, 5, '2024-08-01', NULL);          -- Elena Yu borrowed Pruning Shears (on loan)