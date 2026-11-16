CREATE OR REPLACE FUNCTION public.fn_check_expense_approver()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$


CREATE OR REPLACE FUNCTION public.fn_expense_audit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
