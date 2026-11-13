-- Library Management Database : sample data (all invented)
PRAGMA foreign_keys = ON;

INSERT INTO authors (first_name,last_name,country,birth_year) VALUES
 ('Jane','Austen','UK',1775),
 ('George','Orwell','UK',1903),
 ('Toni','Morrison','USA',1931),
 ('Gabriel','Garcia Marquez','Colombia',1927),
 ('Haruki','Murakami','Japan',1949),
 ('Chinua','Achebe','Nigeria',1930),
 ('Agatha','Christie','UK',1890),
 ('Isaac','Asimov','USA',1920),
 ('Ursula','Le Guin','USA',1929),
 ('Neil','Gaiman','UK',1960),
 ('Terry','Pratchett','UK',1948),
 ('Margaret','Atwood','Canada',1939);

INSERT INTO books (isbn,title,genre,published_year,copies_total,copies_available) VALUES
 ('9780141439518','Pride and Prejudice','Classic',1813,3,3),
 ('9780451524935','1984','Dystopian',1949,4,4),
 ('9780451526342','Animal Farm','Satire',1945,2,2),
 ('9781400033416','Beloved','Historical Fiction',1987,2,2),
 ('9780060883287','One Hundred Years of Solitude','Magical Realism',1967,3,3),
 ('9780307476463','Norwegian Wood','Literary Fiction',1987,2,2),
 ('9780385474542','Things Fall Apart','Classic',1958,3,3),
 ('9780062073488','Murder on the Orient Express','Mystery',1934,3,3),
 ('9780553293357','Foundation','Science Fiction',1951,3,3),
 ('9780441478125','The Left Hand of Darkness','Science Fiction',1969,2,2),
 ('9780380789030','Good Omens','Fantasy',1990,3,3),
 ('9780385490818','The Handmaid''s Tale','Dystopian',1985,3,3),
 ('9780060558123','Coraline','Fantasy',2002,2,2),
 ('9780307474278','Kafka on the Shore','Literary Fiction',2002,2,2);

-- book_id order matches the INSERT order above.
INSERT INTO book_authors (book_id,author_id) VALUES
 (1,1),(2,2),(3,2),(4,3),(5,4),(6,5),(7,6),(8,7),(9,8),(10,9),
 (11,10),(11,11),   -- Good Omens: two authors
 (12,12),(13,10),(14,5);

INSERT INTO members (first_name,last_name,email,phone,join_date,status) VALUES
 ('Alice','Johnson','alice.johnson@example.com','555-0101','2024-01-15','active'),
 ('Bob','Smith','bob.smith@example.com','555-0102','2024-02-20','active'),
 ('Carla','Martinez','carla.martinez@example.com','555-0103','2024-03-05','active'),
 ('David','Lee','david.lee@example.com','555-0104','2024-05-11','active'),
 ('Eva','Chen','eva.chen@example.com','555-0105','2024-06-30','active'),
 ('Frank','Okafor','frank.okafor@example.com','555-0106','2024-08-09','suspended'),
 ('Grace','Patel','grace.patel@example.com','555-0107','2025-01-22','active'),
 ('Henry','Nguyen','henry.nguyen@example.com','555-0108','2025-03-18','active'),
 ('Isla','Brown','isla.brown@example.com','555-0109','2025-07-04','active'),
 ('Jack','Wilson','jack.wilson@example.com','555-0110','2023-11-02','expired');

-- Returned loans (history). Triggers only adjust stock for open loans on INSERT,
-- so these do not change copies_available.
INSERT INTO loans (book_id,member_id,loan_date,due_date,return_date) VALUES
 (2,1,'2026-01-05','2026-01-19','2026-01-17'),
 (1,1,'2026-02-02','2026-02-16','2026-02-14'),
 (9,1,'2026-03-10','2026-03-24','2026-03-30'),   -- returned late
 (2,2,'2026-01-12','2026-01-26','2026-01-25'),
 (8,2,'2026-02-10','2026-02-24','2026-02-24'),
 (5,3,'2026-03-01','2026-03-15','2026-03-12'),
 (4,3,'2026-04-02','2026-04-16','2026-04-28'),   -- returned late
 (11,4,'2026-04-10','2026-04-24','2026-04-22'),
 (12,5,'2026-05-03','2026-05-17','2026-05-16'),
 (2,5,'2026-05-20','2026-06-03','2026-06-01'),
 (3,5,'2026-06-05','2026-06-19','2026-06-18'),
 (7,7,'2026-06-10','2026-06-24','2026-06-23'),
 (10,7,'2026-07-01','2026-07-15','2026-07-20'),  -- returned late
 (13,8,'2026-07-08','2026-07-22','2026-07-21'),
 (2,1,'2026-08-03','2026-08-17','2026-08-15'),
 (9,2,'2026-08-10','2026-08-24','2026-08-23'),
 (6,9,'2026-09-01','2026-09-15','2026-09-10');

-- Currently open loans (INSERT trigger decrements stock). Today ~ 2026-11-13.
INSERT INTO loans (book_id,member_id,loan_date,due_date,return_date) VALUES
 (1,1,'2026-09-20','2026-10-04',NULL),   -- overdue
 (12,2,'2026-10-01','2026-10-15',NULL),  -- overdue
 (5,4,'2026-10-10','2026-10-24',NULL),   -- overdue
 (14,6,'2026-09-15','2026-09-29',NULL),  -- overdue (suspended member)
 (2,3,'2026-10-20','2026-11-03',NULL),   -- overdue
 (8,5,'2026-11-05','2026-11-19',NULL),   -- on time
 (11,8,'2026-11-08','2026-11-22',NULL),  -- on time
 (9,9,'2026-11-10','2026-11-24',NULL),
 (3,1,'2026-10-12','2026-10-26',NULL),   -- overdue (Alice has 2 overdue)
 (3,7,'2026-11-01','2026-11-15',NULL);   -- Animal Farm now fully checked out   -- on time

-- Demonstrate UPDATE / DELETE.
UPDATE members SET phone = '555-0199' WHERE email = 'bob.smith@example.com';
UPDATE members SET status = 'active', join_date = date('now') WHERE email = 'jack.wilson@example.com';  -- renewed
INSERT INTO members (first_name,last_name,email) VALUES ('Temp','Account','temp@example.com');
DELETE FROM members WHERE email = 'temp@example.com';  -- no loans, so FK allows delete
