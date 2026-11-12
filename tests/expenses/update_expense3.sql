-- Expense 2 (Tech Symposium Catering): change approver to core S033 (membership_id 33)
UPDATE expense SET approved_by = 33 WHERE expense_id = 2;