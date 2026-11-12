-- Expense 1 (Tech Symposium): change approver to core S032 (membership_id 32)
UPDATE expense SET approved_by = 32 WHERE expense_id = 1;