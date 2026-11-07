-- Existing triggers (keep these unchanged)
-- T1: a student may be in at most one cultural, one technical
--     and one technical_team club
CREATE OR REPLACE FUNCTION fn_limit_club_types() RETURNS trigger AS $$
DECLARE
    new_type TEXT;
BEGIN
    SELECT c.type INTO new_type FROM club c WHERE c.club_id = NEW.club_id;

    IF new_type IN ('cultural', 'technical', 'technical_team') THEN
        IF EXISTS (
            SELECT 1
            FROM membership m
            JOIN club c ON c.club_id = m.club_id
            WHERE m.roll_number = NEW.roll_number
              AND c.type = new_type
              AND m.membership_id IS DISTINCT FROM NEW.membership_id
        ) THEN
            RAISE EXCEPTION 'Student % is already in a % club', NEW.roll_number, new_type;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_membership_limit
BEFORE INSERT OR UPDATE ON membership
FOR EACH ROW EXECUTE FUNCTION fn_limit_club_types();


-- T-approver: an expense can only be approved by a lead, core or treasurer
CREATE OR REPLACE FUNCTION fn_check_expense_approver() RETURNS trigger AS $$
DECLARE
    approver_pos VARCHAR(15);
BEGIN
    IF NEW.approved_by IS NOT NULL THEN
        SELECT m.position INTO approver_pos
        FROM membership m
        WHERE m.membership_id = NEW.approved_by;

        IF approver_pos NOT IN ('lead', 'core', 'treasurer') THEN
            RAISE EXCEPTION 'Expense can only be approved by a lead, core or treasurer (this member is: %)',
                            approver_pos;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_expense_approver
BEFORE INSERT OR UPDATE OF approved_by ON expense
FOR EACH ROW EXECUTE FUNCTION fn_check_expense_approver();


-- ---------------------------------------------------------------------
-- 4. NEW TRIGGERS
-- ---------------------------------------------------------------------


-- T1: Event capacity check on event_registration
-- BEFORE INSERT OR UPDATE OF status
-- Ignore cancelled. Count registered + attended. Lock row with SELECT FOR UPDATE.
-- Raise error if count >= capacity (NULL capacity = unlimited).
-- On UPDATE, exclude OLD.registration_id. If event_id is invalid, return NEW.
CREATE OR REPLACE FUNCTION fn_check_event_capacity() RETURNS trigger AS $$
DECLARE
    v_capacity INT;
    v_count INT;
BEGIN
    -- Skip if new status is cancelled
    IF NEW.status = 'cancelled' THEN
        RETURN NEW;
    END IF;

    -- If event_id is invalid, return NEW (let FK handle it)
    IF NOT EXISTS (SELECT 1 FROM event WHERE event_id = NEW.event_id) THEN
        RETURN NEW;
    END IF;

    -- Lock event row
    SELECT capacity INTO v_capacity FROM event WHERE event_id = NEW.event_id FOR UPDATE;

    -- Count registrations with status registered or attended
    -- For UPDATE, exclude the old registration_id
    IF TG_OP = 'UPDATE' THEN
        SELECT COUNT(*) INTO v_count
        FROM event_registration
        WHERE event_id = NEW.event_id
          AND status IN ('registered', 'attended')
          AND registration_id != OLD.registration_id;
    ELSE
        -- INSERT
        SELECT COUNT(*) INTO v_count
        FROM event_registration
        WHERE event_id = NEW.event_id
          AND status IN ('registered', 'attended');
    END IF;

    -- Raise error if count >= capacity (NULL capacity = unlimited)
    IF v_capacity IS NOT NULL AND v_count >= v_capacity THEN
        RAISE EXCEPTION 'Event % capacity exceeded: % registered/attended out of %',
            NEW.event_id, v_count + 1, v_capacity;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_capacity
BEFORE INSERT OR UPDATE OF status ON event_registration
FOR EACH ROW EXECUTE FUNCTION fn_check_event_capacity();


-- T2: Registration date check on event_registration, BEFORE INSERT only
-- Reject if event_date < CURRENT_DATE. Allow today/future.
-- Let FK handle invalid event_id.
CREATE OR REPLACE FUNCTION fn_check_registration_date() RETURNS trigger AS $$
BEGIN
    -- Only check for INSERT, not UPDATE
    IF TG_OP = 'INSERT' THEN
        -- Reject if event_date < CURRENT_DATE
        -- Check if event exists and its date is in the past
        IF EXISTS (SELECT 1 FROM event WHERE event_id = NEW.event_id AND event_date < CURRENT_DATE) THEN
            RAISE EXCEPTION 'Event date is in the past: event_id %', NEW.event_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registration_date
BEFORE INSERT ON event_registration
FOR EACH ROW EXECUTE FUNCTION fn_check_registration_date();


-- T3: Membership history on membership DELETE
-- AFTER DELETE FOR EACH ROW: insert OLD data into membership_history
CREATE OR REPLACE FUNCTION fn_membership_history() RETURNS trigger AS $$
BEGIN
    INSERT INTO membership_history (roll_number, club_id, position, left_at)
    VALUES (OLD.roll_number, OLD.club_id, OLD.position, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_membership_history
AFTER DELETE ON membership
FOR EACH ROW EXECUTE FUNCTION fn_membership_history();


-- T4: Expense audit on expense INSERT OR UPDATE OR DELETE
-- AFTER FOR EACH ROW: branch on TG_OP, store old/new data as JSONB
-- Skip update if to_jsonb(OLD) = to_jsonb(NEW) (for UPDATE only)
-- Must capture cascade deletes
CREATE OR REPLACE FUNCTION fn_expense_audit() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO expense_audit (expense_id, operation, old_data, new_data, changed_at)
        VALUES (NEW.expense_id, 'INSERT', NULL::jsonb, to_jsonb(NEW), now());
    ELSIF TG_OP = 'UPDATE' THEN
        -- Skip if old and new data are identical
        IF to_jsonb(OLD) = to_jsonb(NEW) THEN
            RETURN NEW;
        END IF;
        INSERT INTO expense_audit (expense_id, operation, old_data, new_data, changed_at)
        VALUES (NEW.expense_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), now());
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO expense_audit (expense_id, operation, old_data, new_data, changed_at)
        VALUES (OLD.expense_id, 'DELETE', to_jsonb(OLD), NULL::jsonb, now());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_expense_audit
AFTER INSERT OR UPDATE OR DELETE ON expense
FOR EACH ROW EXECUTE FUNCTION fn_expense_audit();


-- T5: Coordinator validation on event
-- AFTER INSERT OR UPDATE OF coordinator_id DEFERRABLE INITIALLY DEFERRED FOR EACH ROW
-- At commit, if coordinator_id IS NOT NULL, verify coordinator's club_id is in event_club for that event
-- If event row was deleted in same TX or coordinator_id IS NULL, pass
-- Fail with error if coordinator is set but event has no event_club rows
CREATE OR REPLACE FUNCTION fn_check_event_coordinator() RETURNS trigger AS $$
DECLARE
    v_club_count INT;
BEGIN
-- If coordinator_id IS NULL, pass
    IF NEW.coordinator_id IS NULL THEN
        RETURN NEW;
    END IF;

-- If event was deleted in same TX, pass
    IF NOT EXISTS (SELECT 1 FROM event WHERE event_id = NEW.event_id) THEN
        RETURN NEW;
    END IF;

-- Verify coordinator's club_id is in event_club for that event
    SELECT COUNT(*) INTO v_club_count
    FROM event_club ec
    WHERE ec.event_id = NEW.event_id
      AND ec.club_id IN (SELECT m.club_id FROM membership m WHERE m.membership_id = NEW.coordinator_id);

-- Fail if coordinator is set but event has no event_club rows for that coordinator's club
    IF v_club_count = 0 THEN
        RAISE EXCEPTION 'Coordinator % is not associated with any club organizing event %',
            NEW.coordinator_id, NEW.event_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_coordinator
AFTER INSERT OR UPDATE OF coordinator_id ON event
FOR EACH ROW EXECUTE FUNCTION fn_check_event_coordinator();