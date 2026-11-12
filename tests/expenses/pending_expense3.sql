-- Expense 11 (Code Review): set approver to NULL (pending)
UPDATE expense SET approved_by = NULL WHERE expense_id = 11;