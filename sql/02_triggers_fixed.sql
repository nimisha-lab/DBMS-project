CREATE OR REPLACE FUNCTION fn_limit_club_types() RETURNS trigger AS $$
DECLARE new_type TEXT;
BEGIN
    SELECT type INTO new_type FROM club WHERE club_id = NEW.club_id;
    IF EXISTS (
        SELECT 1 FROM membership m JOIN club c ON c.club_id=m.club_id
        WHERE m.roll_number=NEW.roll_number AND c.type=new_type
          AND m.membership_id IS DISTINCT FROM NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'Student % is already in a % club', NEW.roll_number, new_type;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_membership_limit ON membership;
CREATE TRIGGER trg_membership_limit BEFORE INSERT OR UPDATE ON membership
FOR EACH ROW EXECUTE FUNCTION fn_limit_club_types();

CREATE OR REPLACE FUNCTION fn_check_expense_approver() RETURNS trigger AS $$
DECLARE approver_pos VARCHAR(15);
BEGIN
    IF NEW.approved_by IS NOT NULL THEN
        SELECT position INTO approver_pos FROM membership
        WHERE membership_id=NEW.approved_by;
        IF approver_pos IS NULL OR approver_pos NOT IN ('lead','core','treasurer') THEN
            RAISE EXCEPTION 'Expense approver must be lead, core, or treasurer';
        END IF;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_expense_approver ON expense;
CREATE TRIGGER trg_expense_approver BEFORE INSERT OR UPDATE OF approved_by ON expense
FOR EACH ROW EXECUTE FUNCTION fn_check_expense_approver();

-- event_registration has composite key (event_id, roll_number), not registration_id.
CREATE OR REPLACE FUNCTION fn_check_event_capacity() RETURNS trigger AS $$
DECLARE v_capacity INT; v_count BIGINT;
BEGIN
    IF NEW.status='cancelled' THEN RETURN NEW; END IF;
    SELECT capacity INTO v_capacity FROM event WHERE event_id=NEW.event_id FOR UPDATE;
    IF NOT FOUND OR v_capacity IS NULL THEN RETURN NEW; END IF;
    SELECT COUNT(*) INTO v_count
    FROM event_registration er
    WHERE er.event_id=NEW.event_id AND er.status IN ('registered','attended')
      AND (TG_OP <> 'UPDATE' OR
           (er.event_id,er.roll_number) IS DISTINCT FROM (OLD.event_id,OLD.roll_number));
    IF v_count >= v_capacity THEN
        RAISE EXCEPTION 'Event % is full (capacity %)', NEW.event_id, v_capacity;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_event_capacity ON event_registration;
CREATE TRIGGER trg_event_capacity
BEFORE INSERT OR UPDATE OF event_id,roll_number,status ON event_registration
FOR EACH ROW EXECUTE FUNCTION fn_check_event_capacity();

CREATE OR REPLACE FUNCTION fn_check_registration_date() RETURNS trigger AS $$
DECLARE v_event_date DATE;
BEGIN
    SELECT event_date INTO v_event_date FROM event WHERE event_id=NEW.event_id;
    IF FOUND AND v_event_date < CURRENT_DATE THEN
        RAISE EXCEPTION 'Cannot register: event % is in the past', NEW.event_id;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_registration_date ON event_registration;
CREATE TRIGGER trg_registration_date BEFORE INSERT ON event_registration
FOR EACH ROW EXECUTE FUNCTION fn_check_registration_date();

CREATE OR REPLACE FUNCTION fn_membership_history() RETURNS trigger AS $$
BEGIN
    INSERT INTO membership_history(roll_number,club_id,position,left_at)
    VALUES(OLD.roll_number,OLD.club_id,OLD.position,CURRENT_TIMESTAMP);
    RETURN OLD;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_membership_history ON membership;
CREATE TRIGGER trg_membership_history AFTER DELETE ON membership
FOR EACH ROW EXECUTE FUNCTION fn_membership_history();

CREATE OR REPLACE FUNCTION fn_expense_audit() RETURNS trigger AS $$
BEGIN
    IF TG_OP='INSERT' THEN
        INSERT INTO expense_audit(expense_id,operation,old_data,new_data,changed_at)
        VALUES(NEW.expense_id,'INSERT',NULL,to_jsonb(NEW),CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF TG_OP='UPDATE' THEN
        IF to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW) THEN
            INSERT INTO expense_audit(expense_id,operation,old_data,new_data,changed_at)
            VALUES(NEW.expense_id,'UPDATE',to_jsonb(OLD),to_jsonb(NEW),CURRENT_TIMESTAMP);
        END IF;
        RETURN NEW;
    ELSE
        INSERT INTO expense_audit(expense_id,operation,old_data,new_data,changed_at)
        VALUES(OLD.expense_id,'DELETE',to_jsonb(OLD),NULL,CURRENT_TIMESTAMP);
        RETURN OLD;
    END IF;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_expense_audit ON expense;
CREATE TRIGGER trg_expense_audit AFTER INSERT OR UPDATE OR DELETE ON expense
FOR EACH ROW EXECUTE FUNCTION fn_expense_audit();

-- Deferred constraint trigger: event_club rows may be inserted later in the transaction.
CREATE OR REPLACE FUNCTION fn_check_event_coordinator() RETURNS trigger AS $$
BEGIN
    IF NEW.coordinator_id IS NULL THEN RETURN NEW; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM membership m
        JOIN event_club ec ON ec.club_id=m.club_id
        WHERE m.membership_id=NEW.coordinator_id AND ec.event_id=NEW.event_id
    ) THEN
        RAISE EXCEPTION 'Coordinator % must belong to a club organising event %',
            NEW.coordinator_id, NEW.event_id;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_event_coordinator ON event;
CREATE CONSTRAINT TRIGGER trg_event_coordinator
AFTER INSERT OR UPDATE ON event
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_check_event_coordinator();
