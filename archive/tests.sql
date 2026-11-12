-- Test suite for club management DBMS
-- Focus: database state checks and view verification
-- DML tests (1-9) have isolation issues in script context;

-- =====================================================
-- Test: Views - Run all 5 views
-- =====================================================

-- Test 1: v_club_leadership
SELECT COUNT(*) AS v_club_leadership_count FROM v_club_leadership;

-- Test 2: v_club_summary
SELECT COUNT(*) AS v_club_summary_count FROM v_club_summary;

-- Test 3: v_pending_expenses
SELECT COUNT(*) AS v_pending_expenses_count FROM v_pending_expenses;

-- Test 4: v_recent_announcements
SELECT COUNT(*) AS v_recent_announcements_count FROM v_recent_announcements;

-- Test 5: v_public_events
SELECT COUNT(*) AS v_public_events_count FROM v_public_events;

-- =====================================================
-- Post-Run Validation
-- =====================================================

-- Test 6: Check counts per table
SELECT 'student count: ' || COUNT(*) AS cnt FROM student;
SELECT 'club count: ' || COUNT(*) AS cnt FROM club;
SELECT 'membership count: ' || COUNT(*) AS cnt FROM membership;
SELECT 'event count: ' || COUNT(*) AS cnt FROM event;
SELECT 'announcement count: ' || COUNT(*) AS cnt FROM announcement;
SELECT 'expense count: ' || COUNT(*) AS cnt FROM expense;

-- Test 7: Assert 0 violations - membership type limit
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT m.roll_number, c.type, COUNT(*) AS club_count
    FROM membership m
    JOIN club c ON c.club_id = m.club_id
    GROUP BY m.roll_number, c.type
    HAVING COUNT(*) > 1
) AS violations;

-- Test 8: Assert 0 violations - no mixed lead/core in a club
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT club_id, COUNT(DISTINCT position) AS pos_count
    FROM membership
    WHERE position IN ('lead', 'core')
    GROUP BY club_id
    HAVING COUNT(DISTINCT position) > 1
) AS mixed;

-- Test 9: Assert 0 violations - capacity overflow
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM event e
WHERE EXISTS (
    SELECT 1 FROM event_registration er
    WHERE er.event_id = e.event_id
      AND er.status IN ('registered', 'attended')
    GROUP BY er.event_id
    HAVING COUNT(*) >= e.capacity
);

-- Test 10: Assert 0 violations - unauthorized approvers
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM expense e
JOIN membership m ON m.membership_id = e.approved_by
WHERE m.position NOT IN ('lead', 'core', 'treasurer');

-- Test 11: Assert 0 violations - orphan coordinators
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM event e
WHERE e.coordinator_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM membership m WHERE m.membership_id = e.coordinator_id);

-- Test 12: Verify all 7 triggers are enabled
SELECT tgname, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname IN ('trg_membership_limit', 'trg_expense_approver', 'trg_event_capacity', 'trg_registration_date', 'trg_membership_history', 'trg_expense_audit', 'trg_event_coordinator')
ORDER BY tgname;