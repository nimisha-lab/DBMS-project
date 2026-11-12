-- Non-destructive demo seed. Run with psql -X -v ON_ERROR_STOP=1 -f seed.sql
-- Does not reset IDs, delete rows, or change existing registrations.
-- Trusted maintenance execution only: date triggers are temporarily disabled within this transaction.
BEGIN;
SELECT pg_advisory_xact_lock(314159, 271828);

-- Fail before inserting anything if either expected trigger is absent or disabled.
DO $check$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgrelid = 'event'::regclass
      AND tgname = 'trg_prevent_past_event' AND tgenabled = 'O'
  ) THEN
    RAISE EXCEPTION 'Required enabled trigger trg_prevent_past_event is missing';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgrelid = 'event_registration'::regclass
      AND tgname = 'trg_registration_date' AND tgenabled = 'O'
  ) THEN
    RAISE EXCEPTION 'Required enabled trigger trg_registration_date is missing';
  END IF;
END $check$;

-- Permit historical demo event creation and registration, but only during
-- this maintenance transaction. PostgreSQL rolls these changes back on error.
ALTER TABLE event DISABLE TRIGGER trg_prevent_past_event;
ALTER TABLE event_registration DISABLE TRIGGER trg_registration_date;

-- Stable mapping between this seed's event keys and actual event IDs.
-- It is independent of event names, which are not unique in the schema.
CREATE TABLE IF NOT EXISTS demo_seed_event (
  seed_key TEXT PRIMARY KEY,
  event_id INT NOT NULL UNIQUE REFERENCES event(event_id) ON DELETE RESTRICT
);


-- students
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
('S050', 'Deepika Roy', '9876543259', 'Computer Science', '4')
ON CONFLICT (roll_number) DO NOTHING;


-- emails
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
('S030', 'priya.d.30@student.example.edu')
ON CONFLICT (email) DO NOTHING;


-- clubs
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
('Curiosity', 'cultural')
ON CONFLICT (name) DO NOTHING;


-- teams
INSERT INTO team (club_id, name) SELECT club_id, 'software' FROM club WHERE name = 'MARS'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'electrical' FROM club WHERE name = 'MARS'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'science' FROM club WHERE name = 'MARS'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'MARS'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'management' FROM club WHERE name = 'MARS'
ON CONFLICT (club_id, name) DO NOTHING;

INSERT INTO team (club_id, name) SELECT club_id, 'software' FROM club WHERE name = 'ASTRA'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'electrical' FROM club WHERE name = 'ASTRA'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'science' FROM club WHERE name = 'ASTRA'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'ASTRA'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'management' FROM club WHERE name = 'ASTRA'
ON CONFLICT (club_id, name) DO NOTHING;

INSERT INTO team (club_id, name) SELECT club_id, 'Outreach' FROM club WHERE name = 'AUV'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'research' FROM club WHERE name = 'AUV'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'mechanical' FROM club WHERE name = 'AUV'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'automation' FROM club WHERE name = 'AUV'
ON CONFLICT (club_id, name) DO NOTHING;

INSERT INTO team (club_id, name) SELECT club_id, 'PRIT' FROM club WHERE name = 'cs club'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'CP' FROM club WHERE name = 'cs club'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'Software' FROM club WHERE name = 'cs club'
ON CONFLICT (club_id, name) DO NOTHING;

INSERT INTO team (club_id, name) SELECT club_id, 'social media' FROM club WHERE name = 'Indicsense'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'ebsb' FROM club WHERE name = 'Indicsense'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'nityakarma' FROM club WHERE name = 'Indicsense'
ON CONFLICT (club_id, name) DO NOTHING;
INSERT INTO team (club_id, name) SELECT club_id, 'Vrittantham' FROM club WHERE name = 'Indicsense'
ON CONFLICT (club_id, name) DO NOTHING;


-- memberships
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
('S050', (SELECT club_id FROM club WHERE name = 'ASTRA'), 'member')
ON CONFLICT (roll_number, club_id) DO NOTHING;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Tech Symposium' AND venue = 'Main Hall'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Tech Symposium', CURRENT_DATE + 10, 'Main Hall', 100, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:tech-symposium',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Cultural Fest' AND venue = 'Auditorium'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Cultural Fest', CURRENT_DATE + 25, 'Auditorium', 150, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:cultural-fest',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Codeathon' AND venue = 'Lab 1'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Codeathon', CURRENT_DATE + 5, 'Lab 1', 50, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:codeathon',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Music Night' AND venue = 'Campus Center'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Music Night', CURRENT_DATE + 30, 'Campus Center', 80, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:music-night',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Debate Competition' AND venue = 'Conference Room'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Debate Competition', CURRENT_DATE + 15, 'Conference Room', 60, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:debate-competition',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:robotics-workshop') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Robotics Workshop' AND venue = 'Lab 2'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Robotics Workshop', CURRENT_DATE + 20, 'Lab 2', 40, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:robotics-workshop',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:design-expo') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Design Expo' AND venue = 'Exhibition Hall'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Design Expo', CURRENT_DATE + 35, 'Exhibition Hall', 120, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:design-expo',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Winter Workshop' AND venue = 'Workshop Room'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Winter Workshop', CURRENT_DATE - 30, 'Workshop Room', 40, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:winter-workshop',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:summer-retreat') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Summer Retreat' AND venue = 'Campus Forest'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Summer Retreat', CURRENT_DATE - 45, 'Campus Forest', 30, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:summer-retreat',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Hackathon' AND venue = 'Lab 2'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Hackathon', CURRENT_DATE - 20, 'Lab 2', 70, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:hackathon',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Code Review' AND venue = 'Conference Room'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Code Review', CURRENT_DATE - 35, 'Conference Room', 50, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:code-review',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Tech Talk' AND venue = 'Seminar Hall'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Tech Talk', CURRENT_DATE + 20, 'Seminar Hall', 50, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:tech-talk',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Workshop' AND venue = 'Room A'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Workshop', CURRENT_DATE + 35, 'Room A', NULL, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:workshop',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Guest Lecture' AND venue = 'Auditorium'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Guest Lecture', CURRENT_DATE + 50, 'Auditorium', 120, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:guest-lecture',v_id);
  END IF;
END $seed$;

DO $seed$
DECLARE v_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch') THEN
    SELECT MIN(event_id) INTO v_id FROM event
    WHERE name = 'Startup Pitch' AND venue = 'Incubator'
    HAVING COUNT(*) = 1;
    IF v_id IS NULL OR EXISTS (SELECT 1 FROM demo_seed_event WHERE event_id = v_id) THEN
      INSERT INTO event(name,event_date,venue,capacity,coordinator_id)
      VALUES ('Startup Pitch', CURRENT_DATE + 8, 'Incubator', 30, NULL)
      RETURNING event_id INTO v_id;
    END IF;
    INSERT INTO demo_seed_event(seed_key,event_id) VALUES ('seed-v1:startup-pitch',v_id);
  END IF;
END $seed$;


-- event-club links
INSERT INTO event_club (event_id, club_id) VALUES
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), (SELECT club_id FROM club WHERE name = 'developers club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), (SELECT club_id FROM club WHERE name = 'imagix')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), (SELECT club_id FROM club WHERE name = 'footlights')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon'), (SELECT club_id FROM club WHERE name = 'cs club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'), (SELECT club_id FROM club WHERE name = 'footlights')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition'), (SELECT club_id FROM club WHERE name = 'Curiosity')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:robotics-workshop'), (SELECT club_id FROM club WHERE name = 'MARS')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop'), (SELECT club_id FROM club WHERE name = 'AUV')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'), (SELECT club_id FROM club WHERE name = 'MARS')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'), (SELECT club_id FROM club WHERE name = 'cs club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk'), (SELECT club_id FROM club WHERE name = 'system coding club')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture'), (SELECT club_id FROM club WHERE name = 'ASTRA')),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'), (SELECT club_id FROM club WHERE name = 'cs club'))
ON CONFLICT (event_id, club_id) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), roll_number,
    CASE WHEN rn <= 80 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'))
ORDER BY rn
LIMIT 100
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), roll_number,
    CASE WHEN rn <= 120 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'))
ORDER BY rn
LIMIT 160
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon'), roll_number,
    CASE WHEN rn <= 40 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon'))
ORDER BY rn
LIMIT 50
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'), roll_number,
    CASE WHEN rn <= 60 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'))
ORDER BY rn
LIMIT 80
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition'), roll_number,
    CASE WHEN rn <= 48 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition'))
ORDER BY rn
LIMIT 60
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop'), roll_number,
    CASE WHEN rn <= 32 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop'))
ORDER BY rn
LIMIT 40
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:summer-retreat'), roll_number,
    CASE WHEN rn <= 24 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:summer-retreat'))
ORDER BY rn
LIMIT 30
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'), roll_number,
    CASE WHEN rn <= 56 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'))
ORDER BY rn
LIMIT 70
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review'), roll_number,
    CASE WHEN rn <= 40 THEN 'attended' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review'))
ORDER BY rn
LIMIT 50
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk'), roll_number,
    CASE WHEN rn <= 40 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk'))
ORDER BY rn
LIMIT 50
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'), roll_number, 'registered'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'))
ORDER BY rn
LIMIT 30
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'), roll_number, 'attended'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'))
ORDER BY rn
OFFSET 30
LIMIT 20
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture'), roll_number,
    CASE WHEN rn <= 96 THEN 'registered' ELSE 'cancelled' END
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture'))
ORDER BY rn
LIMIT 120
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'), roll_number, 'registered'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'))
ORDER BY rn
LIMIT 14
ON CONFLICT (event_id, roll_number) DO NOTHING;

INSERT INTO event_registration (event_id, roll_number, status)
SELECT (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'), roll_number, 'attended'
FROM (SELECT roll_number, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn FROM student WHERE roll_number ~ '^S0[0-5][0-9]$' AND roll_number BETWEEN 'S001' AND 'S050') sub
WHERE NOT EXISTS (SELECT 1 FROM event_registration existing WHERE existing.event_id = (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'))
ORDER BY rn
OFFSET 14
LIMIT 15
ON CONFLICT (event_id, roll_number) DO NOTHING;


-- budgets
INSERT INTO budget (event_id, estimated, allotted) VALUES
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), 5000.00, 5500.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), 8000.00, 7000.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon'), 3000.00, 3000.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'), 2000.00, 2500.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition'), 1500.00, 1500.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop'), 500.00, 600.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:summer-retreat'), 300.00, 300.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'), 4000.00, 4500.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review'), 800.00, 800.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk'), 1000.00, 900.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'), 100.00, 150.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture'), 2000.00, 2500.00),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'), 1000.00, 800.00)
ON CONFLICT (event_id) DO NOTHING;

CREATE TEMP TABLE seed_expense (
 event_id INT, description TEXT, amount NUMERIC(10,2), spent_on DATE, approved_by INT
) ON COMMIT DROP;

INSERT INTO seed_expense (event_id, description, amount, spent_on, approved_by) VALUES
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), 'Venue rental and AV equipment', 2000.00, CURRENT_DATE - 5, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), 'Catering services', 1500.00, CURRENT_DATE - 3, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S018' AND club_id = (SELECT club_id FROM club WHERE name = 'developers club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), 'Stage setup and lighting', 3000.00, CURRENT_DATE - 10, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S003' AND club_id = (SELECT club_id FROM club WHERE name = 'imagix'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), 'Decorations and props', 1200.00, CURRENT_DATE - 8, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S009' AND club_id = (SELECT club_id FROM club WHERE name = 'footlights'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:codeathon'), 'Prizes and refreshments', 1200.00, CURRENT_DATE - 2, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S024' AND club_id = (SELECT club_id FROM club WHERE name = 'cs club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'), 'Sound system rental', 800.00, CURRENT_DATE - 1, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S009' AND club_id = (SELECT club_id FROM club WHERE name = 'footlights'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:debate-competition'), 'Judge fees and certificates', 600.00, CURRENT_DATE - 1, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S012' AND club_id = (SELECT club_id FROM club WHERE name = 'Curiosity'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:winter-workshop'), 'Materials and handouts', 200.00, CURRENT_DATE - 35, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:summer-retreat'), 'Camping gear and food', 150.00, CURRENT_DATE - 50, NULL),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:hackathon'), 'Prizes and mentorship kits', 2000.00, CURRENT_DATE - 25, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S027' AND club_id = (SELECT club_id FROM club WHERE name = 'MARS'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:code-review'), 'Refreshments and material', 400.00, CURRENT_DATE - 40, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-talk'), 'Speaker fee and handouts', 600.00, CURRENT_DATE - 15, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:workshop'), 'Materials and snacks', 100.00, CURRENT_DATE - 40, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S015' AND club_id = (SELECT club_id FROM club WHERE name = 'system coding club'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:guest-lecture'), 'Speaker fee and travel', 1500.00, CURRENT_DATE - 5, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S030' AND club_id = (SELECT club_id FROM club WHERE name = 'ASTRA'))),
((SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:startup-pitch'), 'Judges'' travel and certificates', 500.00, CURRENT_DATE - 3, 
 (SELECT membership_id FROM membership WHERE roll_number = 'S024' AND club_id = (SELECT club_id FROM club WHERE name = 'cs club')));

INSERT INTO expense(event_id,description,amount,spent_on,approved_by)
SELECT se.event_id,se.description,se.amount,se.spent_on,se.approved_by
FROM seed_expense se
WHERE NOT EXISTS (
 SELECT 1 FROM expense e WHERE e.event_id=se.event_id AND e.description=se.description
);

CREATE TEMP TABLE seed_announcement (
 club_id INT, team_id INT, event_id INT, title TEXT, body TEXT, posted_at TIMESTAMP
) ON COMMIT DROP;

INSERT INTO seed_announcement (club_id, team_id, event_id, title, body, posted_at) VALUES
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:tech-symposium'), 
 'Tech Symposium Announcement', 'Welcome to the Tech Symposium! See you there.', CURRENT_DATE - 3),
((SELECT club_id FROM club WHERE name = 'cs club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'cs club') AND name = 'PRIT'), 
 NULL, 'PRIT Update', 'PRIT team meeting scheduled for next week.', CURRENT_DATE - 7),
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, NULL, 
'General Notice', 'Important general notice for all members.', CURRENT_DATE - 14),
((SELECT club_id FROM club WHERE name = 'footlights'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), 
 'Cultural Fest Lineup', 'Check the Cultural Fest schedule on the website.', CURRENT_DATE - 10),
((SELECT club_id FROM club WHERE name = 'Indicsense'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'Indicsense') AND name = 'social media'), 
 NULL, 'Social Media Workshop', 'Learn social media promotion strategies.', CURRENT_DATE - 21),
((SELECT club_id FROM club WHERE name = 'MARS'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:robotics-workshop'), 
 'Robotics Workshop Reminder', 'Dont forget the Robotics Workshop this Thursday.', CURRENT_DATE - 5),
((SELECT club_id FROM club WHERE name = 'Curiosity'), NULL, NULL, 
 'Curiosity Announcement', 'New executive board elected for Curiosity.', CURRENT_DATE - 28),
((SELECT club_id FROM club WHERE name = 'ASTRA'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:design-expo'), 
 'Design Expo Preparations', 'Design Expo planning meeting on Monday.', CURRENT_DATE - 18),
((SELECT club_id FROM club WHERE name = 'cs club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'cs club') AND name = 'Software'), 
 NULL, 'Software Project Update', 'Midterm project submissions due soon.', CURRENT_DATE - 9),
((SELECT club_id FROM club WHERE name = 'imagix'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:cultural-fest'), 
 'Imagix at Cultural Fest', 'Imagix will have a stall at Cultural Fest.', CURRENT_DATE - 15),
((SELECT club_id FROM club WHERE name = 'Indicsense'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'Indicsense') AND name = 'social media'), 
 NULL, 'Indicsense Workshop', 'Indicsense cultural workshop this weekend.', CURRENT_DATE - 30),
((SELECT club_id FROM club WHERE name = 'AUV'), NULL, NULL, 
 'AUV General Notice', 'AUV general body meeting rescheduled.', CURRENT_DATE - 35),
((SELECT club_id FROM club WHERE name = 'footlights'), NULL, 
 (SELECT event_id FROM demo_seed_event WHERE seed_key = 'seed-v1:music-night'), 
 'Music Night Lineup', 'Performing artists announced for Music Night.', CURRENT_DATE - 2),
((SELECT club_id FROM club WHERE name = 'cs club'), 
 (SELECT team_id FROM team WHERE club_id = (SELECT club_id FROM club WHERE name = 'cs club') AND name = 'CP'), 
 NULL, 'CP Competition', 'CP competition qualifiers announced.', CURRENT_DATE - 12);

INSERT INTO announcement(club_id,team_id,event_id,title,body,posted_at)
SELECT sa.club_id,sa.team_id,sa.event_id,sa.title,sa.body,sa.posted_at
FROM seed_announcement sa
WHERE NOT EXISTS (
 SELECT 1 FROM announcement a WHERE a.club_id=sa.club_id AND a.title=sa.title
);

-- Commit the seed first: PostgreSQL cannot ALTER a table while its
-- foreign-key/constraint trigger events are still pending in this transaction.
COMMIT;

-- IMPORTANT: Run only during maintenance, with the application stopped.
-- Restore both protections immediately in a separate transaction.
BEGIN;
ALTER TABLE event_registration ENABLE TRIGGER trg_registration_date;
ALTER TABLE event ENABLE TRIGGER trg_prevent_past_event;
COMMIT;

-- Confirm both triggers are enabled before restarting the application.
DO $verify$
BEGIN
  IF EXISTS (
    SELECT 1 FROM (VALUES
      ('event'::regclass, 'trg_prevent_past_event'),
      ('event_registration'::regclass, 'trg_registration_date')
    ) AS expected(table_oid, trigger_name)
    WHERE NOT EXISTS (
      SELECT 1 FROM pg_trigger t
      WHERE t.tgrelid = expected.table_oid
        AND t.tgname = expected.trigger_name AND t.tgenabled = 'O'
    )
  ) THEN
    RAISE EXCEPTION 'Seed completed but a date-validation trigger is not enabled';
  END IF;
END $verify$;
