CREATE OR REPLACE VIEW v_club_leadership AS
SELECT c.club_id,c.name AS club_name,m.position,s.name AS student_name
FROM club c LEFT JOIN membership m ON c.club_id=m.club_id
AND m.position IN ('president','secretary','treasurer')
LEFT JOIN student s ON s.roll_number=m.roll_number;

CREATE OR REPLACE VIEW v_club_summary AS
SELECT c.club_id,c.name AS club_name,c.type,
(SELECT COUNT(*) FROM membership m WHERE m.club_id=c.club_id) AS member_count,
(SELECT COUNT(*) FROM team t WHERE t.club_id=c.club_id) AS team_count,
(SELECT COUNT(*) FROM event_club ec WHERE ec.club_id=c.club_id) AS event_count
FROM club c;

CREATE OR REPLACE VIEW v_pending_expenses AS
SELECT e.expense_id,e.event_id,ev.name AS event_name,
string_agg(DISTINCT c.name,', ' ORDER BY c.name) AS club_names,
e.description,e.amount,e.spent_on
FROM expense e JOIN event ev ON ev.event_id=e.event_id
LEFT JOIN event_club ec ON ec.event_id=e.event_id
LEFT JOIN club c ON c.club_id=ec.club_id
WHERE e.approved_by IS NULL
GROUP BY e.expense_id,e.event_id,ev.name,e.description,e.amount,e.spent_on;

CREATE OR REPLACE VIEW v_recent_announcements AS
SELECT a.announcement_id,a.title,a.body,a.posted_at,c.name AS club_name,t.name AS team_name
FROM announcement a LEFT JOIN club c ON c.club_id=a.club_id
LEFT JOIN team t ON t.team_id=a.team_id AND t.club_id=a.club_id
WHERE a.posted_at >= CURRENT_TIMESTAMP - INTERVAL '14 days';

CREATE OR REPLACE VIEW v_public_events AS
SELECT name AS event_name,event_date,venue FROM event;
