from app.db import query, execute

OFFICER_POSITIONS = ("president", "secretary", "treasurer", "lead", "core")
APPROVER_POSITIONS = ("treasurer", "lead", "core")

def _membership(roll_number, club_id):
    return query(
        """SELECT membership_id, position
           FROM membership
           WHERE roll_number=%s AND club_id=%s""",
        (roll_number, club_id), one=True
    )

def officer_membership(roll_number, club_id):
    row = _membership(roll_number, club_id)
    if not row or row["position"] not in OFFICER_POSITIONS:
        return None
    return row

def dashboard_data(club_id):
    club = query("SELECT club_id, name, type FROM club WHERE club_id=%s",
                 (club_id,), one=True)
    if not club:
        return None
    stats = query(
        """SELECT
             (SELECT COUNT(*) FROM membership WHERE club_id=%s) AS member_count,
             (SELECT COUNT(*) FROM team WHERE club_id=%s) AS team_count,
             (SELECT COUNT(*) FROM event_club WHERE club_id=%s) AS event_count,
             (SELECT COUNT(*) FROM event_club ec JOIN event e ON e.event_id=ec.event_id
                WHERE ec.club_id=%s AND e.event_date >= CURRENT_DATE) AS upcoming_event_count,
             (SELECT COUNT(*) FROM expense x
                JOIN event_club ec ON ec.event_id=x.event_id
                WHERE ec.club_id=%s AND x.approved_by IS NULL) AS pending_expense_count""",
        (club_id, club_id, club_id, club_id, club_id), one=True
    )
    upcoming_events = query(
        """SELECT e.event_id, e.name, e.event_date, e.venue, e.capacity
           FROM event e JOIN event_club ec ON ec.event_id=e.event_id
           WHERE ec.club_id=%s AND e.event_date >= CURRENT_DATE
           ORDER BY e.event_date, e.event_id LIMIT 6""", (club_id,)
    )
    return {"club": club, "stats": stats, "upcoming_events": upcoming_events}

def list_members(club_id):
    return query(
        """SELECT m.membership_id, m.roll_number, s.name AS student_name,
                  s.department, s.year, m.position, t.name AS team_name
           FROM membership m
           JOIN student s ON s.roll_number=m.roll_number
           LEFT JOIN team t ON t.team_id=m.team_id AND t.club_id=m.club_id
           WHERE m.club_id=%s
           ORDER BY CASE m.position
             WHEN 'president' THEN 1 WHEN 'secretary' THEN 2
             WHEN 'treasurer' THEN 3 WHEN 'lead' THEN 4
             WHEN 'core' THEN 5 ELSE 6 END, s.name""", (club_id,)
    )

def list_teams(club_id):
    return query("SELECT team_id, name FROM team WHERE club_id=%s ORDER BY name",
                 (club_id,))

def create_event(club_id, roll_number, name, event_date, venue, capacity,
                 estimated, allotted):
    officer = officer_membership(roll_number, club_id)
    if not officer:
        raise ValueError("Your account is not an officer of this club.")
    if not name.strip():
        raise ValueError("Event name is required.")
    if capacity is not None and capacity <= 0:
        raise ValueError("Capacity must be a positive number.")
    if estimated < 0 or allotted < 0:
        raise ValueError("Budget amounts cannot be negative.")

    # The event and its club link are inserted in one transaction. The deferred
    # coordinator trigger validates the club association at transaction commit.
    from app.db import connect
    with connect() as conn:
        with conn.cursor() as cur:
            # Insert with a NULL coordinator first because this repository's
            # coordinator trigger runs immediately (it is not deferred).
            cur.execute(
                """INSERT INTO event (name, event_date, venue, capacity, coordinator_id)
                   VALUES (%s, %s, %s, %s, NULL) RETURNING event_id""",
                (name.strip(), event_date, venue.strip() or None, capacity)
            )
            event_id = cur.fetchone()[0]
            cur.execute(
                "INSERT INTO event_club (event_id, club_id) VALUES (%s, %s)",
                (event_id, club_id)
            )
            # Now the club link exists, so coordinator validation succeeds.
            cur.execute(
                "UPDATE event SET coordinator_id=%s WHERE event_id=%s",
                (officer["membership_id"], event_id)
            )
            cur.execute(
                """INSERT INTO budget (event_id, estimated, allotted)
                   VALUES (%s, %s, %s)""",
                (event_id, estimated, allotted)
            )
    return event_id

def expense_data(club_id):
    pending = query(
        """SELECT x.expense_id, x.event_id, ev.name AS event_name,
                  x.description, x.amount, x.spent_on
           FROM expense x
           JOIN event ev ON ev.event_id=x.event_id
           JOIN event_club ec ON ec.event_id=x.event_id
           WHERE ec.club_id=%s AND x.approved_by IS NULL
           ORDER BY x.spent_on DESC, x.expense_id DESC""", (club_id,)
    )
    history = query(
        """SELECT x.expense_id, x.event_id, ev.name AS event_name,
                  x.description, x.amount, x.spent_on, x.approved_by,
                  approver.roll_number AS approver_roll
           FROM expense x
           JOIN event ev ON ev.event_id=x.event_id
           JOIN event_club ec ON ec.event_id=x.event_id
           LEFT JOIN membership approver ON approver.membership_id=x.approved_by
           WHERE ec.club_id=%s AND x.approved_by IS NOT NULL
           ORDER BY x.spent_on DESC, x.expense_id DESC LIMIT 30""", (club_id,)
    )
    return {"pending": pending, "history": history}

def approve_expense(club_id, roll_number, expense_id):
    officer = _membership(roll_number, club_id)
    if not officer or officer["position"] not in APPROVER_POSITIONS:
        raise ValueError("Only a treasurer, lead, or core member can approve expenses.")
    changed = execute(
        """UPDATE expense x
           SET approved_by=%s
           WHERE x.expense_id=%s
             AND x.approved_by IS NULL
             AND EXISTS (
               SELECT 1 FROM event_club ec
               WHERE ec.event_id=x.event_id AND ec.club_id=%s
             )""",
        (officer["membership_id"], expense_id, club_id)
    )
    if changed == 0:
        raise ValueError("That expense is not pending for this club, or it was already processed.")
    return changed


def budget_data(club_id):
    """Return event budgets belonging to this club, plus totals."""
    rows = query(
        """SELECT e.event_id, e.name AS event_name, e.event_date,
                  b.estimated, b.allotted,
                  COALESCE((SELECT SUM(x.amount) FROM expense x
                            WHERE x.event_id=e.event_id), 0) AS spent,
                  (SELECT COUNT(*) FROM expense x
                   WHERE x.event_id=e.event_id AND x.approved_by IS NULL) AS pending_expenses
           FROM event e
           JOIN event_club ec ON ec.event_id=e.event_id
           LEFT JOIN budget b ON b.event_id=e.event_id
           WHERE ec.club_id=%s
           ORDER BY e.event_date DESC, e.event_id DESC""", (club_id,)
    )
    totals = {
        "estimated": sum((r["estimated"] or 0) for r in rows),
        "allotted": sum((r["allotted"] or 0) for r in rows),
        "spent": sum((r["spent"] or 0) for r in rows),
    }
    return {"rows": rows, "totals": totals}

def club_analysis(club_id):
    """Club-only analysis; it does not expose other clubs' information."""
    return query(
        """SELECT
             (SELECT COUNT(*) FROM event_club ec WHERE ec.club_id=%s) AS events_organized,
             (SELECT COUNT(DISTINCT er.event_id)
                FROM event_registration er
                JOIN event_club ec ON ec.event_id=er.event_id
               WHERE ec.club_id=%s) AS events_with_participants,
             (SELECT COUNT(*) FROM event_registration er
                JOIN event_club ec ON ec.event_id=er.event_id
               WHERE ec.club_id=%s) AS total_registrations,
             (SELECT COUNT(DISTINCT er.roll_number) FROM event_registration er
                JOIN event_club ec ON ec.event_id=er.event_id
               WHERE ec.club_id=%s) AS unique_participants,
             (SELECT COUNT(*) FROM event_club ec JOIN event e ON e.event_id=ec.event_id
               WHERE ec.club_id=%s AND e.event_date >= CURRENT_DATE) AS upcoming_events,
             (SELECT COUNT(*) FROM membership WHERE club_id=%s) AS total_members,
             (SELECT COUNT(*) FROM team WHERE club_id=%s) AS total_teams""",
        (club_id, club_id, club_id, club_id, club_id, club_id, club_id), one=True
    )
