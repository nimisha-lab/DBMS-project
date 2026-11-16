
CREATE OR REPLACE FUNCTION public.fn_check_budget_update()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    approved_total NUMERIC;
BEGIN
    -- Locking the budget row during UPDATE is handled
    -- by PostgreSQL's normal row-level locking.

    SELECT COALESCE(SUM(x.amount), 0)
    INTO approved_total
    FROM expense x
    WHERE x.event_id = NEW.event_id
      AND x.approved_by IS NOT NULL;

    IF NEW.allotted < approved_total THEN
        RAISE EXCEPTION
            'Cannot reduce allotted budget below approved expenses. Event: %, Approved: %, Requested allotment: %',
            NEW.event_id,
            approved_total,
            NEW.allotted;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_budget_update ON public.budget;

CREATE TRIGGER trg_check_budget_update
BEFORE UPDATE OF allotted
ON public.budget
FOR EACH ROW
EXECUTE FUNCTION public.fn_check_budget_update();
