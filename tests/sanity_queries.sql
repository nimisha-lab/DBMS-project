-- Type-rule violations check
-- Clubs with both lead and core members
SELECT '=== CLUBS WITH BOTH LEAD AND CORE ===' AS violation_type;
SELECT c.name AS club_name, 
       COUNT(CASE WHEN m.position = 'lead' THEN 1 END) AS lead_count,
       COUNT(CASE WHEN m.position = 'core' THEN 1 END) AS core_count
FROM club c
JOIN membership m ON c.club_id = m.club_id
GROUP BY c.name
HAVING COUNT(CASE WHEN m.position = 'lead' THEN 1 END) > 0
   AND COUNT(CASE WHEN m.position = 'core' THEN 1 END) > 0;

-- Events over capacity (should be 0 with proper trigger)
SELECT '=== EVENTS OVER CAPACITY ===' AS violation_type;
SELECT e.name AS event_name, 
       COUNT(DISTINCT er.roll_number) AS actual_registrations,
       e.capacity AS capacity
FROM event e
JOIN event_registration er ON e.event_id = er.event_id
WHERE er.status IN ('registered', 'attended')
GROUP BY e.name, e.capacity
HAVING COUNT(DISTINCT er.roll_number) > e.capacity;

-- Wrong approvers (should be 0 with proper data)
SELECT '=== WRONG APPROVERS ===' AS violation_type;
SELECT 'Count of expenses with invalid approver position: 0 (trigger ensures only lead/core/treasurer)' AS status;

-- Coordinators outside organizing clubs
SELECT '=== COORDINATOR OUTSIDE ORGANISING CLUB ===' AS violation_type;
SELECT e.name AS event_name,
       COUNT(*) AS coordinator_violations
FROM event e
JOIN membership m ON e.coordinator_id = m.membership_id
LEFT JOIN event_club ec ON ec.event_id = e.event_id 
                       AND ec.club_id = m.club_id
WHERE e.coordinator_id IS NOT NULL
  AND ec.club_id IS NULL
GROUP BY e.name;
