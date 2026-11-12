-- Expense 1 (Tech Symposium): change approver from treasurer S015 to lead S031
UPDATE expense SET approved_by = 31 WHERE event_id = 1 AND description = 'Venue rental and AV equipment';