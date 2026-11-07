SELECT 'students' AS metric, COUNT(*) AS value FROM student
UNION ALL SELECT 'clubs', COUNT(*) FROM club
UNION ALL SELECT 'events', COUNT(*) FROM event
UNION ALL SELECT 'registrations', COUNT(*) FROM event_registration
UNION ALL SELECT 'expenses', COUNT(*) FROM expense
UNION ALL SELECT 'memberships', COUNT(*) FROM membership
UNION ALL SELECT 'announcements', COUNT(*) FROM announcement;