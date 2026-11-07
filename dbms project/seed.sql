-- Seed data for club management DB
-- Wrapped in single transaction
BEGIN;

-- =====================================================
-- 0. Reset: truncate all tables and reset identities
-- =====================================================
TRUNCATE 
    expense, budget, event_registration, event_club, event, 
    membership, team, club, student_email, student, 
    announcement, membership_history, expense_audit
RESTARt IDENTITY CASCADE;

-- =====================================================
-- 1. Temporarily disable registration date trigger
-- =====================================================
ALTER TABLE event_registration DISABLE TRIGGER trg_registration_date;

-- =====================================================
-- 2. Seed: Students (50 students, S001-S050, each roll number unique)
-- =====================================================
INSERT INTO student (roll_number, name, phone_number, department, year) VALUES
('S001', 'Aarav Patel', '9876543210', 'Computer Science', '2'),
('S002', 'Ananya Sharma', '9876543211', 'Electronics', '3'),
('S003', 'Vihaan Singh', '9876543212', 'Mechanical', '2'),
('S004', 'Sara Khan', '9876543213', 'Civil', '1'),
('S005', 'Kabir Singh', '9876543214', 'Computer Science', '4'),
('S006', 'Priya Patel', '9876543215', 'Electronics', '2'),
('S007', 'Rohit Das', '9876543216', 'Mechanical', '3'),
('S008', 'Simran Johar', '9876543217', 'Civil', '1'),
('S009', 'Arjun Mehta', '9876543218', 'Computer Science', '2'),
('S010', 'Deepika Roy', '9876543219', 'Electronics', '4'),
('S011', 'Vihaan Patel', '9876543220', 'Mechanical', '1'),
('S012', 'Ananya Singh', '9876543221', 'Computer Science', '3'),
('S013', 'Kabir Das', '9876543222', 'Electronics', '2'),
('S014', 'Priya Singh', '9876543223', 'Civil', '4'),
('S015', 'Rohit Patel', '9876543224', 'Computer Science', '1'),
('S016', 'Simran Roy', '9876543225', 'Electronics', '3'),
('S017', 'Arjun Sharma', '9876543226', 'Mechanical', '2'),
('S018', 'Deepika Patel', '9876543227', 'Civil', '1'),
('S019', 'Vihaan Khan', '9876543228', 'Computer Science', '4'),
('S020', 'Ananya Das', '9876543229', 'Electronics', '2'),
('S021', 'Kabir Roy', '9876543230', 'Mechanical', '3'),
('S022', 'Priya Sharma', '9876543231', 'Computer Science', '1'),
('S023', 'Rohit Singh', '9876543232', 'Electronics', '4'),
('S024', 'Simran Khan', '9876543233', 'Computer Science', '2'),
('S025', 'Arjun Das', '9876543234', 'Mechanical', '3'),
('S026', 'Deepika Roy', '9876543235', 'Computer Science', '1'),
('S027', 'Vihaan Sharma', '9876543236', 'Electronics', '4'),
('S028', 'Ananya Singh', '9876543237', 'Computer Science', '2'),
('S029', 'Kabir Patel', '9876543238', 'Mechanical', '1'),
('S030', 'Priya Das', '9876543239', 'Computer Science', '3'),
('S031', 'Rohit Roy', '9876543240', 'Electronics', '2'),
('S032', 'Simran Sharma', '9876543241', 'Computer Science', '1'),
('S033', 'Arjun Das', '9876543242', 'Electronics', '4'),
('S034', 'Vihaan Sharma', '9876543243', 'Mechanical', '3'),
('S035', 'Kabir Singh', '9876543244', 'Electronics', '4'),
('S036', 'Simran Sharma', '9876543245', 'Computer Science', '1'),
('S037', 'Arjun Patel', '9876543246', 'Mechanical', '2'),
('S038', 'Deepika Roy', '9876543247', 'Electronics', '3'),
('S039', 'Priya Roy', '9876543248', 'Mechanical', '4'),
('S040', 'Rohit Das', '9876543249', 'Electronics', '1'),
('S041', 'Simran Patel', '9876543250', 'Computer Science', '2'),
('S042', 'Arjun Das', '9876543251', 'Mechanical', '3'),
('S043', 'Deepika Roy', '9876543252', 'Computer Science', '4'),
('S044', 'Ananya Sharma', '9876543253', 'Electronics', '3'),
('S045', 'Kabir Patel', '9876543254', 'Computer Science', '2'),
('S046', 'Priya Roy', '9876543255', 'Mechanical', '4'),
('S047', 'Rohit Das', '9876543256', 'Electronics', '1'),
('S048', 'Simran Patel', '9876543257', 'Computer Science', '3'),
('S049', 'Arjun Das', '9876543258', 'Mechanical', '2'),
('S050', 'Deepika Roy', '9876543259', 'Computer Science', '4');

-- Student emails (1-2 each, unique emails)
INSERT INTO student_email (roll_number, email) VALUES
('S001', 'aarav.patel@student.example.edu'),
('S001', 'aarav.personal@example.edu'),
('S002', 'ananya.sharma@student.example.edu'),
('S003', 'vihaan.singh@student.example.edu'),
('S004', 'sara.khan@student.example.edu'),
('S005', 'kabir.singh@student.example.edu'),
('S006', 'priya.patel@student.example.edu'),
('S007', 'rohit.das@student.example.edu'),
('S008', 'simran.johar@student.example.edu'),
('S009', 'arjun.mehta@student.example.edu'),
('S010', 'deepika.roy.10@student.example.edu'),
('S011', 'vihaan.patel@student.example.edu'),
('S012', 'ananya.singh@student.example.edu'),
('S013', 'kabir.das@student.example.edu'),
('S014', 'priya.singh@student.example.edu'),
('S015', 'rohit.patel@student.example.edu'),
('S016', 'simran.roy@student.example.edu'),
('S017', 'arjun.sharma@student.example.edu'),
('S018', 'deepika.pat.18@student.example.edu'),
('S019', 'vihaan.khan@student.example.edu'),
('S020', 'ananya.d.20@student.example.edu'),
('S021', 'kabir.roy@student.example.edu'),
('S022', 'priya.sharma@student.example.edu'),
('S023', 'rohit.s.23@student.example.edu'),
('S024', 'simran.k@student.example.edu'),
('S025', 'arjun.das@student.example.edu'),
('S026', 'deepika.r.26@student.example.edu'),
('S027', 'vihaan.s.27@student.example.edu'),
('S028', 'ananya.s.28@student.example.edu'),
('S029', 'kabir.p.29@student.example.edu'),
('S030', 'priya.d.30@student.example.edu');

-- =====================================================
-- 3. Seed: Clubs (10 clubs)
-- =====================================================
INSERT INTO club (name, type) VALUES
('imagix', 'cultural'),
('Indicsense', 'cultural'),
('system coding club', 'technical'),
('developers club', 'technical'),
('MARS', 'technical_team'),
('ASTRA', 'technical_team'),
('AUV', 'technical'),
('cs club', 'technical'),
('footlights', 'cultural'),
('Curiosity', 'cultural');

-- =====================================================
-- 4. Seed: Teams (21 teams)
-- =====================================================
INSERT INTO team (club_id, name) SELECT club_id, 'software' FROM club WHERE name = 'MARS';
INSERT INTO team (club_id, name) SELECT club_id, 'electrical' FROM club WHERE name = 'MARS';
INSERT INTO team (club_id, name) SELECT club_id, 'science' FROM club WHERE name = 'MARS';
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'MARS';
INSERT INTO team (club_id, name) SELECT club_id, 'management' FROM club WHERE name = 'MARS';

INSERT INTO team (club_id, name) SELECT club_id, 'software' FROM club WHERE name = 'ASTRA';
INSERT INTO team (club_id, name) SELECT club_id, 'electrical' FROM club WHERE name = 'ASTRA';
INSERT INTO team (club_id, name) SELECT club_id, 'science' FROM club WHERE name = 'ASTRA';
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'ASTRA';
INSERT INTO team (club_id, name) SELECT club_id, 'management' FROM club WHERE name = 'ASTRA';

INSERT INTO team (club_id, name) SELECT club_id, 'Outreach' FROM club WHERE name = 'AUV';
INSERT INTO team (club_id, name) SELECT club_id, 'research' FROM club WHERE name = 'AUV';
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'AUV';
INSERT INTO team (club_id, name) SELECT club_id, 'automation' FROM club WHERE name = 'AUV';

INSERT INTO team (club_id, name) SELECT club_id, 'PRIT' FROM club WHERE name = 'cs club';
INSERT INTO team (club_id, name) SELECT club_id, 'CP' FROM club WHERE name = 'cs club';
INSERT INTO team (club_id, name) SELECT club_id, 'Software' FROM club WHERE name = 'cs club';

INSERT INTO team (club_id, name) SELECT club_id, 'social media' FROM club WHERE name = 'Indicsense';
INSERT INTO team (club_id, name) SELECT club_id, 'ebsb' FROM club WHERE name = 'Indicsense';
INSERT INTO team (club_id, name) SELECT club_id, 'nityakarma' FROM club WHERE name = 'Indicsense';
INSERT INTO team (club_id, name) SELECT club_id, 'Vrittantham' FROM club WHERE name = 'Indicsense';

-- =====================================================
-- 5. Seed: Memberships
-- =====================================================
INSERT INTO membership (roll_number, club_id, position) VALUES
('S001', (SELECT club_id FROM club WHERE name = 'imagix'), 'president'),
('S002', (SELECT club_id FROM club WHERE name = 'imagix'), 'secretary'),
('S003', (SELECT club_id FROM club WHERE name = 'imagix'), 'treasurer'),
('S004', (SELECT club_id FROM club WHERE name = 'Indicsense'), 'president'),
('S005', (SELECT club_id FROM club WHERE name = 'Indicsense'), 'secretary'),
('S006', (SELECT club_id FROM club WHERE name = 'Indicsense'), 'treasurer'),
('S007', (SELECT club_id FROM club WHERE name = 'footlights'), 'president'),
('S008', (SELECT club_id FROM club WHERE name = 'footlights'), 'secretary'),
('S009', (SELECT club_id FROM club WHERE name = 'footlights'), 'treasurer'),
('S010', (SELECT club_id FROM club WHERE name = 'Curiosity'), 'president'),
('S011', (SELECT club_id FROM club WHERE name = 'Curiosity'), 'secretary'),
('S012', (SELECT club_id FROM club WHERE name = 'Curiosity'), 'treasurer'),
('S013', (SELECT club_id FROM club WHERE name = 'system coding club'), 'president'),
('S014', (SELECT club_id FROM club WHERE name = 'system coding club'), 'secretary'),
('S015', (SELECT club_id FROM club WHERE name = 'system coding club'), 'treasurer'),
('S016', (SELECT club_id FROM club WHERE name = 'developers club'), 'president'),
('S017', (SELECT club_id FROM club WHERE name = 'developers club'), 'secretary'),
('S018', (SELECT club_id FROM club WHERE name = 'developers club'), 'treasurer'),
('S019', (SELECT club_id FROM club WHERE name = 'AUV'), 'president'),
('S020', (SELECT club_id FROM club WHERE name = 'AUV'), 'secretary'),
('S021', (SELECT club_id FROM club WHERE name = 'AUV'), 'treasurer'),
('S022', (SELECT club_id FROM club WHERE name = 'cs club'), 'president'),
('S023', (SELECT club_id FROM club WHERE name = 'cs club'), 'secretary'),
('S024', (SELECT club_id FROM club WHERE name = 'cs club'), 'treasurer'),
('S025', (SELECT club_id FROM club WHERE name = 'MARS'), 'president'),
('S026', (SELECT club_id FROM club WHERE name = 'MARS'), 'secretary'),
('S027', (SELECT club_id FROM club WHERE name = 'MARS'), 'treasurer'),
('S028', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'president'),
('S029', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'secretary'),
('S030', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'treasurer'),
('S031', (SELECT club_id FROM club WHERE name = 'imagix'), 'member'),
('S032', (SELECT club_id FROM club WHERE name = 'system coding club'), 'member'),
('S033', (SELECT club_id FROM club WHERE name = 'MARS'), 'member'),
('S034', (SELECT club_id FROM club WHERE name = 'footlights'), 'member'),
('S035', (SELECT club_id FROM club WHERE name = 'developers club'), 'member'),
('S036', (SELECT club_id FROM club WHERE name = 'Curiosity'), 'member'),
('S037', (SELECT club_id FROM club WHERE name = 'MARS'), 'member'),
('S038', (SELECT club_id FROM club WHERE name = 'cs club'), 'member'),
('S039', (SELECT club_id FROM club WHERE name = 'footlights'), 'member'),
('S040', (SELECT club_id FROM club WHERE name = 'system coding club'), 'member'),
('S041', (SELECT club_id FROM club WHERE name = 'MARS'), 'member'),
('S042', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'member'),
('S043', (SELECT club_id FROM club WHERE name = 'imagix'), 'member'),
('S044', (SELECT club_id FROM club WHERE name = 'developers club'), 'member'),
('S045', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'member'),
('S046', (SELECT club_id FROM club WHERE name = 'Curiosity'), 'member'),
('S047', (SELECT club_id FROM club WHERE name = 'MARS'), 'member'),
('S048', (SELECT club_id FROM club WHERE name = 'cs club'), 'member'),
('S049', (SELECT club_id FROM club WHERE name = 'MARS'), 'member'),
('S050', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'member');

-- =====================================================
-- 6. Seed: Events (15 events with realistic names)
-- =====================================================
INSERT INTO event (name, event_date, venue, capacity, coordinator_id) VALUES
('Tech Symposium', CURRENT_DATE + 10, 'Main Hall', 100, NULL),
('Cultural Fest', CURRENT_DATE + 25, 'Auditorium', 150, NULL),
('Codeathon', CURRENT_DATE + 5, 'Lab 1', 50, NULL),
('Music Night', CURRENT_DATE + 30, 'Campus Center', 80, NULL),
('Debate Competition', CURRENT_DATE + 15, 'Conference Room', 60, NULL),
('Robotics Workshop', CURRENT_DATE + 20, 'Lab 2', 40, NULL),
('Design Expo', CURRENT_DATE + 35, 'Exhibition Hall', 120, NULL),
('Winter Workshop', CURRENT_DATE - 30, 'Workshop Room', 40, NULL),
('Summer Retreat', CURRENT_DATE - 45, 'Campus Forest', 30, NULL),
('Hackathon', CURRENT_DATE - 20, 'Lab 2', 70, NULL),
('Code Review', CURRENT_DATE - 35, 'Conference Room', 50, NULL),
('Tech Talk', CURRENT_DATE + 20, 'Seminar Hall', 50, NULL),
('Workshop', CURRENT_DATE + 35, 'Room A', NULL, NULL),
('Guest Lecture', CURRENT_DATE + 50, 'Auditorium', 120, NULL),
('Startup Pitch', CURRENT_DATE + 8, 'Incubator', 30, NULL);

-- =====================================================
-- 7. Seed: event_club
-- =====================================================
INSERT INTO event_club (event_id, club_id) VALUES
((SELECT event_id FROM event WHERE name = 'Tech Symposium'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM event WHERE name = 'Tech Symposium'), (SELECT club_id FROM club WHERE name = 'developers club')),
((SELECT event_id FROM event WHERE name = 'Cultural Fest'), (SELECT club_id FROM club WHERE name = 'imagix')),
((SELECT event_id FROM event WHERE name = 'Cultural Fest'), (SELECT club_id FROM club WHERE name = 'footlights')),
((SELECT event_id FROM event WHERE name = 'Codeathon'), (SELECT club_id FROM club WHERE name = 'cs club')),
((SELECT event_id FROM event WHERE name = 'Music Night'), (SELECT club_id FROM club WHERE name = 'footlights')),
((SELECT event_id FROM event WHERE name = 'Debate Competition'), (SELECT club_id FROM club WHERE name = 'Curiosity')),
((SELECT event_id FROM event WHERE name = 'Robotics Workshop'), (SELECT club_id FROM club WHERE name = 'MARS')),
((SELECT event_id FROM event WHERE name = 'Winter Workshop'), (SELECT club_id FROM club WHERE name = 'AUV')),
((SELECT event_id FROM event WHERE name = 'Hackathon'), (SELECT club_id FROM club WHERE name = 'MARS')),
((SELECT event_id FROM event WHERE name = 'Hackathon'), (SELECT club_id FROM club WHERE name = 'cs club')),
((SELECT event_id FROM event WHERE name = 'Code Review'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM event WHERE name = 'Tech Talk'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM event WHERE name = 'Guest Lecture'), (SELECT club_id FROM club WHERE name = 'ASTRA')),
((SELECT event_id FROM event WHERE name = 'Startup Pitch'), (SELECT club_id FROM club WHERE name = 'cs club'));

-- =====================================================
-- 8. Seed: Registrations
-- =====================================================
-- Use derived table (no CTE naming conflicts)

-- Tech Symposium (capacity 100): 80 registered, 20 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Tech Symposium'), roll_number,
    CASE WHEN rn <= 80 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 100;

-- Cultural Fest (capacity 150): 120 registered, 40 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Cultural Fest'), roll_number,
    CASE WHEN rn <= 120 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 160;

-- Codeathon (capacity 50): 40 registered, 10 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Codeathon'), roll_number,
    CASE WHEN rn <= 40 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 50;

-- Music Night (capacity 80): 60 registered, 20 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Music Night'), roll_number,
    CASE WHEN rn <= 60 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 80;

-- Debate Competition (capacity 60): 48 registered, 12 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Debate Competition'), roll_number,
    CASE WHEN rn <= 48 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 60;

-- Winter Workshop (capacity 40): 32 attended, 8 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Winter Workshop'), roll_number,
    CASE WHEN rn <= 32 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 40;

-- Summer Retreat (capacity 30): 24 attended, 6 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Summer Retreat'), roll_number,
    CASE WHEN rn <= 24 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 30;

-- Hackathon (capacity 70): 56 attended, 14 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Hackathon'), roll_number,
    CASE WHEN rn <= 56 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 70;

-- Code Review (capacity 50): 40 attended, 10 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Code Review'), roll_number,
    CASE WHEN rn <= 40 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 50;

-- Tech Talk (capacity 50): 40 registered, 10 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Tech Talk'), roll_number,
    CASE WHEN rn <= 40 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 50;

-- Workshop (NULL capacity): registered and attended (unlimited, non-overlapping)
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Workshop'), roll_number, 'registered'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 30;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Workshop'), roll_number, 'attended'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
OFFSET 30
LIMIT 20;

-- Guest Lecture (capacity 120): 96 registered, 24 cancelled
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Guest Lecture'), roll_number,
    CASE WHEN rn <= 96 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 120;

-- Startup Pitch (capacity 30): 29 registrations (14 registered + 15 attended)
INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Startup Pitch'), roll_number, 'registered'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
LIMIT 14;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM event WHERE name = 'Startup Pitch'), roll_number, 'attended'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student) sub
ORDER BY rn
OFFSET 14
LIMIT 15;

-- =====================================================
-- 9. Seed: Budgets and Expenses
-- =====================================================
INSERT INTO budget (event_id, estimated, allotted) VALUES
((SELECT event_id FROM event WHERE name = 'Tech Symposium'), 5000.00, 5500.00),
((SELECT event_id FROM event WHERE name = 'Cultural Fest'), 8000.00, 7000.00),
((SELECT event_id FROM event WHERE name = 'Codeathon'), 3000.00, 3000.00),
((SELECT event_id FROM event WHERE name = 'Music Night'), 2000.00, 2500.00),
((SELECT event_id FROM event WHERE name = 'Debate Competition'), 1500.00, 1500.00),
((SELECT event_id FROM event WHERE name = 'Winter Workshop'), 500.00, 600.00),
((SELECT event_id FROM event WHERE name = 'Summer Retreat'), 300.00, 300.00),
((SELECT event_id FROM event WHERE name = 'Hackathon'), 4000.00, 4500.00),
((SELECT event_id FROM event WHERE name = 'Code Review'), 800.00, 800.00),
((SELECT event_id FROM event WHERE name = 'Tech Talk'), 1000.00, 900.00),
((SELECT event_id FROM event WHERE name = 'Workshop'), 100.00, 150.00),
((SELECT event_id FROM event WHERE name = 'Guest Lecture'), 2000.00, 2500.00),
((SELECT event_id FROM event WHERE name = 'Startup Pitch'), 1000.00, 800.00);

INSERT INTO expense (event_id, description, amount, spent_on, approved_by) VALUES
((SELECT event_id FROM event WHERE name = 'Tech Symposium'), 'Venue rental and AV equipment', 2000.00, CURRENT_DATE - 5, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM event WHERE name = 'Tech Symposium'), 'Catering services', 1500.00, CURRENT_DATE - 3, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S018' AND club_id = (SELECT club_id FROM club WHERE name = 'developers club'))),
((SELECT event_id FROM event WHERE name = 'Cultural Fest'), 'Stage setup and lighting', 3000.00, CURRENT_DATE - 10, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S003' AND club_id = (SELECT club_id FROM club WHERE name = 'imagix'))),
((SELECT event_id FROM event WHERE name = 'Cultural Fest'), 'Decorations and props', 1200.00, CURRENT_DATE - 8, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S009' AND club_id = (SELECT club_id FROM club WHERE name = 'footlights'))),
((SELECT event_id FROM event WHERE name = 'Codeathon'), 'Prizes and refreshments', 1200.00, CURRENT_DATE - 2, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S024' AND club_id = (SELECT club_id FROM club WHERE name = 'cs club'))),
((SELECT event_id FROM event WHERE name = 'Music Night'), 'Sound system rental', 800.00, CURRENT_DATE - 1, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S009' AND club_id = (SELECT club_id FROM club WHERE name = 'footlights'))),
((SELECT event_id FROM event WHERE name = 'Debate Competition'), 'Judge fees and certificates', 600.00, CURRENT_DATE - 1, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S012' AND club_id = (SELECT club_id FROM club WHERE name = 'Curiosity'))),
((SELECT event_id FROM event WHERE name = 'Winter Workshop'), 'Materials and handouts', 200.00, CURRENT_DATE - 35, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM event WHERE name = 'Summer Retreat'), 'Camping gear and food', 150.00, CURRENT_DATE - 50, NULL),
((SELECT event_id FROM event WHERE name = 'Hackathon'), 'Prizes and mentorship kits', 2000.00, CURRENT_DATE - 25, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S027' AND club_id = (SELECT club_id FROM club WHERE name = 'MARS'))),
((SELECT event_id FROM event WHERE name = 'Code Review'), 'Refreshments and material', 400.00, CURRENT_DATE - 40, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM event WHERE name = 'Tech Talk'), 'Speaker fee and handouts', 600.00, CURRENT_DATE - 15, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM event WHERE name = 'Workshop'), 'Materials and snacks', 100.00, CURRENT_DATE - 40, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM event WHERE name = 'Guest Lecture'), 'Speaker fee and travel', 1500.00, CURRENT_DATE - 5, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S030' AND club_id = (SELECT club_id FROM club WHERE name = 'ASTRA'))),
((SELECT event_id FROM event WHERE name = 'Startup Pitch'), 'Judges'' travel and certificates', 500.00, CURRENT_DATE - 3, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S024' AND club_id = (SELECT club_id FROM club WHERE name = 'cs club')));

-- =====================================================
-- 10. Seed: Announcements
-- =====================================================
INSERT INTO announcement (club_id, team_id, event_id, title, body, posted_at) VALUES
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Tech Symposium'), 
 'Tech Symposium Announcement', 'Welcome to the Tech Symposium! See you there.', CURRENT_DATE - 3),
((SELECT club_id FROM club WHERE name = 'system coding club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'system coding club') AND name = 'PRIT'), 
 NULL, 'PRIT Update', 'PRIT team meeting scheduled for next week.', CURRENT_DATE - 7),
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, NULL, 
'General Notice', 'Important general notice for all members.', CURRENT_DATE - 14),
((SELECT club_id FROM club WHERE name = 'footlights'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Cultural Fest'), 
 'Cultural Fest Lineup', 'Check the Cultural Fest schedule on the website.', CURRENT_DATE - 10),
((SELECT club_id FROM club WHERE name = 'footlights'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'footlights') AND name = 'social media'), 
 NULL, 'Social Media Workshop', 'Learn social media promotion strategies.', CURRENT_DATE - 21),
((SELECT club_id FROM club WHERE name = 'MARS'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Robotics Workshop'), 
 'Robotics Workshop Reminder', 'Dont forget the Robotics Workshop this Thursday.', CURRENT_DATE - 5),
((SELECT club_id FROM club WHERE name = 'Curiosity'), NULL, NULL, 
 'Curiosity Announcement', 'New executive board elected for Curiosity.', CURRENT_DATE - 28),
((SELECT club_id FROM club WHERE name = 'ASTRA'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Design Expo'), 
 'Design Expo Preparations', 'Design Expo planning meeting on Monday.', CURRENT_DATE - 18),
((SELECT club_id FROM club WHERE name = 'cs club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'cs club') AND name = 'Software'), 
 NULL, 'Software Project Update', 'Midterm project submissions due soon.', CURRENT_DATE - 9),
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Cultural Fest'), 
 'Imagix at Cultural Fest', 'Imagix will have a stall at Cultural Fest.', CURRENT_DATE - 15),
((SELECT club_id FROM club WHERE name = 'Indicsense'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'Indicsense') AND name = 'social media'), 
 NULL, 'Indicsense Workshop', 'Indicsense cultural workshop this weekend.', CURRENT_DATE - 30),
((SELECT club_id FROM club WHERE name = 'AUV'), NULL, NULL, 
 'AUV General Notice', 'AUV general body meeting rescheduled.', CURRENT_DATE - 35),
((SELECT club_id FROM club WHERE name = 'footlights'), NULL, 
 (SELECT event_id FROM event WHERE name = 'Music Night'), 
 'Music Night Lineup', 'Performing artists announced for Music Night.', CURRENT_DATE - 2),
((SELECT club_id FROM club WHERE name = 'system coding club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'system coding club') AND name = 'CP'), 
 NULL, 'CP Competition', 'CP competition qualifiers announced.', CURRENT_DATE - 12);

-- =====================================================
-- 11. Re-enable registration date trigger
-- =====================================================
ALTER TABLE event_registration ENABLE TRIGGER trg_registration_date;

-- =====================================================
-- 12. Commit
-- =====================================================
COMMIT;