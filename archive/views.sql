-- v_club_leadership: current office-bearers (president, secretary, treasurer)
-- Clubs without leaders appear with NULLs (LEFT JOIN with filter in ON)
-- Handles duplicate positions; excludes lead/core/coordinator/member
CREATE VIEW v_club_leadership AS
SELECT 
    c.club_id, 
    c.name AS club_name, 
    m.position, 
    s.name AS student_name
FROM club c
LEFT JOIN membership m ON c.club_id = m.club_id AND m.position IN ('president', 'secretary', 'treasurer')
LEFT JOIN student s ON m.roll_number = s.roll_number;

-- v_club_summary: club counts preventing join fan-out via subqueries/COUNT(DISTINCT)
-- Missing counts default to 0
CREATE VIEW v_club_summary AS
SELECT 
    c.club_id, 
    c.name AS club_name, 
    c.type, 
    (SELECT COUNT(*) FROM membership m WHERE m.club_id = c.club_id) AS member_count,
    (SELECT COUNT(*) FROM team t WHERE t.club_id = c.club_id) AS team_count,
    (SELECT COUNT(*) FROM event_club ec WHERE ec.club_id = c.club_id) AS event_count
FROM club c;

-- v_pending_expenses: expenses pending approval, with aggregated club names
-- Filter approved_by IS NULL, LEFT JOIN event clubs (null if unassigned)
CREATE VIEW v_pending_expenses AS
SELECT 
    e.expense_id, 
    e.event_id, 
    ev.name AS event_name, 
    string_agg(DISTINCT c.name, ', ' ORDER BY c.name) AS club_names, 
    e.description, 
    e.amount, 
    e.spent_on
FROM expense e
JOIN event ev ON e.event_id = ev.event_id
LEFT JOIN event_club ec ON e.event_id = ec.event_id
LEFT JOIN club c ON ec.club_id = c.club_id
WHERE e.approved_by IS NULL
GROUP BY e.expense_id, e.event_id, ev.name, e.description, e.amount, e.spent_on;

-- v_recent_announcements: announcements from last 14 days
-- Filter by posted_at >= CURRENT_DATE - 14, order by posted_at DESC
-- LEFT JOIN team and event
CREATE VIEW v_recent_announcements AS
SELECT 
    a.announcement_id, 
    a.title, 
    a.body, 
    a.posted_at, 
    c.name AS club_name, 
    t.name AS team_name
FROM announcement a
LEFT JOIN club c ON a.club_id = c.club_id
LEFT JOIN team t ON a.team_id = t.team_id AND a.club_id = t.club_id
WHERE a.posted_at >= CURRENT_DATE - 14
ORDER BY a.posted_at DESC;

-- v_public_events: all events, no financial/capacity/coordinator data
CREATE VIEW v_public_events AS
SELECT 
    name AS event_name, 
    event_date, 
    venue
FROM event;