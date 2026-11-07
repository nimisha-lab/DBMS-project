-- Expense 3 (Cultural Fest Stage): change approver to lead S034 (membership_id 34, footlights club organizing Cultural Fest)
UPDATE expense SET approved_by = 34 WHERE expense_id = 3;