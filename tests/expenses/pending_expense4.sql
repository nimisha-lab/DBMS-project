-- Expense 12 (Tech Talk): set approver to NULL (pending)
UPDATE expense SET approved_by = NULL WHERE expense_id = 12;