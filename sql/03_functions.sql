CREATE OR REPLACE FUNCTION approve_expense(
    p_expense_id INTEGER,
    p_approver_membership_id INTEGER
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE v_position VARCHAR(15);
BEGIN
    SELECT position INTO v_position FROM membership
    WHERE membership_id=p_approver_membership_id;
    IF NOT FOUND OR v_position NOT IN ('lead','core','treasurer') THEN
        RAISE EXCEPTION 'Only a lead, core member, or treasurer can approve an expense';
    END IF;
    UPDATE expense SET approved_by=p_approver_membership_id
    WHERE expense_id=p_expense_id AND approved_by IS NULL;
    IF NOT FOUND THEN
        IF EXISTS(SELECT 1 FROM expense WHERE expense_id=p_expense_id) THEN
            RAISE EXCEPTION 'Expense % has already been approved',p_expense_id;
        ELSE
            RAISE EXCEPTION 'Expense % does not exist',p_expense_id;
        END IF;
    END IF;
END; $$;
