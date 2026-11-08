SELECT 'student' AS table_name,COUNT(*) AS row_count FROM student
UNION ALL SELECT 'club',COUNT(*) FROM club
UNION ALL SELECT 'team',COUNT(*) FROM team
UNION ALL SELECT 'membership',COUNT(*) FROM membership
UNION ALL SELECT 'event',COUNT(*) FROM event
UNION ALL SELECT 'event_registration',COUNT(*) FROM event_registration
UNION ALL SELECT 'budget',COUNT(*) FROM budget
UNION ALL SELECT 'expense',COUNT(*) FROM expense
UNION ALL SELECT 'announcement',COUNT(*) FROM announcement
UNION ALL SELECT 'user_account',COUNT(*) FROM user_account
ORDER BY table_name;

-- All following integrity queries should return zero rows.
SELECT er.event_id,COUNT(*) AS active_registrations,e.capacity
FROM event_registration er JOIN event e ON e.event_id=er.event_id
WHERE er.status IN ('registered','attended') AND e.capacity IS NOT NULL
GROUP BY er.event_id,e.capacity HAVING COUNT(*) > e.capacity;

SELECT m.roll_number,c.type,COUNT(*) AS memberships
FROM membership m JOIN club c ON c.club_id=m.club_id
GROUP BY m.roll_number,c.type HAVING COUNT(*) > 1;

SELECT e.expense_id,m.position FROM expense e
JOIN membership m ON m.membership_id=e.approved_by
WHERE m.position NOT IN ('lead','core','treasurer');

SELECT e.event_id,e.coordinator_id FROM event e
WHERE e.coordinator_id IS NOT NULL AND NOT EXISTS(
 SELECT 1 FROM membership m JOIN event_club ec ON ec.club_id=m.club_id
 WHERE m.membership_id=e.coordinator_id AND ec.event_id=e.event_id
);

SELECT tgname,tgrelid::regclass AS table_name,tgenabled
FROM pg_trigger WHERE NOT tgisinternal AND tgname IN (
'trg_membership_limit','trg_expense_approver','trg_event_capacity',
'trg_registration_date','trg_membership_history','trg_expense_audit',
'trg_event_coordinator') ORDER BY tgname;
