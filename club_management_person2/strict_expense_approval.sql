CREATE OR REPLACE FUNCTION public.fn_check_expense_approver()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    approver_pos VARCHAR(15);
    approver_club_id INTEGER;
    allotted_amount NUMERIC;
    approved_total NUMERIC;
BEGIN
    -- Lock the budget to serialize approvals.
    SELECT allotted INTO allotted_amount
    FROM budget
    WHERE event_id = NEW.event_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No budget exists for event %', NEW.event_id;
    END IF;

    -- Validate new approvals and changes to approved amounts/events.
    -- Unrelated edits to historical approvals remain possible.
    IF NEW.approved_by IS NOT NULL
       AND (
           TG_OP = 'INSERT'
           OR NEW.approved_by IS DISTINCT FROM OLD.approved_by
           OR NEW.amount IS DISTINCT FROM OLD.amount
           OR NEW.event_id IS DISTINCT FROM OLD.event_id
       )
    THEN
        SELECT position, club_id
        INTO approver_pos, approver_club_id
        FROM membership
        WHERE membership_id = NEW.approved_by;

        IF approver_pos IS NULL
           OR approver_pos NOT IN ('treasurer', 'lead', 'core')
        THEN
            RAISE EXCEPTION 'Unauthorized expense approver';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM event_club
            WHERE event_id = NEW.event_id
              AND club_id = approver_club_id
        ) THEN
            RAISE EXCEPTION 'Approver does not belong to an organizing club';
        END IF;

        SELECT COALESCE(SUM(amount), 0)
        INTO approved_total
        FROM expense
        WHERE event_id = NEW.event_id
          AND approved_by IS NOT NULL
          AND expense_id IS DISTINCT FROM NEW.expense_id;

        IF approved_total + NEW.amount > allotted_amount THEN
            RAISE EXCEPTION 'Expense exceeds allotted budget';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_expense_approver ON public.expense;

CREATE TRIGGER trg_expense_approver
BEFORE INSERT OR UPDATE
ON public.expense
FOR EACH ROW
EXECUTE FUNCTION public.fn_check_expense_approver();