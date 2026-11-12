-- Run:  CREATE DATABASE club_management_db;          (once, from psql)
--       psql -U postgres -d club_management_db -f schema.sql
-- Re-runnable: everything is dropped and rebuilt each time.

-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. DROP (reverse dependency order)
-- ---------------------------------------------------------------------


-- 1. student
CREATE TABLE  IF NOT EXISTS student (
    roll_number   VARCHAR(12) PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    phone_number  VARCHAR(10),
    department    VARCHAR(25) NOT NULL,
    year          VARCHAR(1),
    CONSTRAINT chk_student_year CHECK (year BETWEEN '1' AND '4')   
);

-- 2 student_email  (multivalued attribute of student)
CREATE TABLE  IF NOT EXISTS student_email (
    roll_number  VARCHAR(12) NOT NULL
                 REFERENCES student(roll_number) ON DELETE CASCADE,   
    email        VARCHAR(50) NOT NULL,
    PRIMARY KEY (roll_number, email),                                 
    CONSTRAINT uq_email UNIQUE (email),                               
    CONSTRAINT chk_email CHECK (email LIKE '%@%')
);

-- 3 club
CREATE TABLE IF NOT EXISTS club (
    club_id  SERIAL PRIMARY KEY,                                       
    name     VARCHAR(50) NOT NULL UNIQUE,
    type     VARCHAR(25) NOT NULL                                      
             CHECK (type IN ('cultural', 'technical', 'technical_team'))
);

-- 4 team
CREATE TABLE IF NOT EXISTS team (
    team_id  SERIAL PRIMARY KEY,                                      
    club_id  INT NOT NULL REFERENCES club(club_id) ON DELETE CASCADE,  
    name     VARCHAR(50) NOT NULL,                                     
    CONSTRAINT uq_team_club_name UNIQUE (club_id, name),
    CONSTRAINT uq_team_id_club   UNIQUE (team_id, club_id)           
);

-- 5 membership
CREATE TABLE  IF NOT EXISTS membership (
    membership_id  SERIAL PRIMARY KEY,
    roll_number    VARCHAR(12) NOT NULL
                   REFERENCES student(roll_number) ON DELETE CASCADE,
    club_id        INT NOT NULL
                   REFERENCES club(club_id) ON DELETE CASCADE,
    team_id        INT,                                                
    position       VARCHAR(15) NOT NULL DEFAULT 'member',

    CONSTRAINT uq_membership UNIQUE (roll_number, club_id),
    CONSTRAINT chk_position  CHECK (position IN
        ('member', 'coordinator', 'secretary', 'treasurer', 'president', 'lead', 'core')),
    CONSTRAINT fk_member_team FOREIGN KEY (team_id, club_id)
        REFERENCES team (team_id, club_id)
);

-- 6 event
CREATE TABLE IF NOT EXISTS event (
    event_id        SERIAL PRIMARY KEY,                                
    name            VARCHAR(50) NOT NULL,                              
    event_date      DATE NOT NULL,                                     
    venue           VARCHAR(50),                                       
    capacity        INT,
    coordinator_id  INT REFERENCES membership(membership_id) ON DELETE SET NULL,
    CONSTRAINT chk_capacity CHECK (capacity > 0)                      
);

-- 7 event_club  (clubs organising an event: many-to-many)
CREATE TABLE IF NOT EXISTS event_club (
    event_id  INT REFERENCES event(event_id) ON DELETE CASCADE,       
    club_id   INT REFERENCES club(club_id)   ON DELETE CASCADE,        
    PRIMARY KEY (event_id, club_id)
);

-- 8 event_registration
CREATE TABLE IF NOT EXISTS event_registration (
    event_id       INT NOT NULL REFERENCES event(event_id) ON DELETE CASCADE,         
    roll_number    VARCHAR(12) NOT NULL
                   REFERENCES student(roll_number) ON DELETE CASCADE,                 
    registered_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,                      
    status         VARCHAR(15) NOT NULL DEFAULT 'registered'                          
                   CHECK (status IN ('registered', 'attended', 'cancelled')),
    PRIMARY KEY (event_id, roll_number)
);

-- 9 budget  (weak entity: one budget per event)
CREATE TABLE IF NOT EXISTS budget (
    event_id   INT PRIMARY KEY
               REFERENCES event(event_id) ON DELETE CASCADE,
    estimated  NUMERIC(10,2) NOT NULL DEFAULT 0,
    allotted   NUMERIC(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_estimated CHECK (estimated >= 0),
    CONSTRAINT chk_allotted  CHECK (allotted  >= 0)
);

-- 10 expense   
CREATE TABLE IF NOT EXISTS expense (
    expense_id   SERIAL PRIMARY KEY,
    event_id     INT NOT NULL REFERENCES budget(event_id) ON DELETE CASCADE,
    description  VARCHAR(200) NOT NULL,
    amount       NUMERIC(10,2) NOT NULL,
    spent_on     DATE NOT NULL DEFAULT CURRENT_DATE,
    approved_by  INT REFERENCES membership(membership_id) ON DELETE SET NULL,
    CONSTRAINT chk_expense_amount CHECK (amount > 0)
);
-- 11 announcement
CREATE TABLE IF NOT EXISTS announcement (
    announcement_id SERIAL PRIMARY KEY,
    club_id         INT NOT NULL REFERENCES club(club_id) ON DELETE CASCADE,
    team_id         INT NULL,
    event_id        INT NULL REFERENCES event(event_id) ON DELETE SET NULL,
    title           VARCHAR(100) NOT NULL,
    body            TEXT NOT NULL,
    posted_at       TIMESTAMP NOT NULL DEFAULT now(),
    FOREIGN KEY (team_id, club_id) REFERENCES team(team_id, club_id)
);

-- 12 membership_history (no FKs)
CREATE TABLE IF NOT EXISTS membership_history (
    history_id SERIAL PRIMARY KEY,
    roll_number  VARCHAR(12) NOT NULL,
    club_id      INT      NOT NULL,
    position     VARCHAR(15) NOT NULL,
    left_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- 13 expense_audit (no FKs)
CREATE TABLE IF NOT EXISTS expense_audit (
    audit_id      SERIAL PRIMARY KEY,
    expense_id    INT      NOT NULL,
    operation     VARCHAR(6) NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
    old_data      JSONB,
    new_data      JSONB,
    changed_at    TIMESTAMP NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 2. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_membership_club ON membership(club_id);
CREATE INDEX IF NOT EXISTS idx_event_date      ON event(event_date);
CREATE INDEX IF NOT EXISTS idx_expense_event   ON expense(event_id);


-- ---------------------------------------------------------------------
-- 3. FUNCTIONS AND TRIGGERS   (NOT YET RUN in your terminal)
-- ---------------------------------------------------------------------