
from datetime import date
from decimal import Decimal, InvalidOperation

from app.db import query, execute, connect


OFFICER_POSITIONS = (
    "president",
    "secretary",
    "treasurer",
    "lead",
    "core"
)

APPROVER_POSITIONS = (
    "treasurer",
    "lead",
    "core"
)


# --------------------------------------------------
# MEMBERSHIP AND PERMISSIONS
# --------------------------------------------------

def _membership(roll_number, club_id):
    return query(
        """
        SELECT membership_id, position
        FROM membership
        WHERE roll_number = %s
          AND club_id = %s
        """,
        (roll_number, club_id),
        one=True
    )


def officer_membership(roll_number, club_id):
    row = _membership(roll_number, club_id)

    if not row or row["position"] not in OFFICER_POSITIONS:
        return None

    return row


# --------------------------------------------------
# OFFICER DASHBOARD
# --------------------------------------------------

def dashboard_data(club_id):
    club = query(
        """
        SELECT club_id, name, type
        FROM club
        WHERE club_id = %s
        """,
        (club_id,),
        one=True
    )

    if not club:
        return None

    stats = query(
        """
        SELECT
            (
                SELECT COUNT(*)
                FROM membership
                WHERE club_id = %s
            ) AS member_count,

            (
                SELECT COUNT(*)
                FROM team
                WHERE club_id = %s
            ) AS team_count,

            (
                SELECT COUNT(*)
                FROM event_club
                WHERE club_id = %s
            ) AS event_count,

            (
                SELECT COUNT(*)
                FROM event_club ec
                JOIN event e
                    ON e.event_id = ec.event_id
                WHERE ec.club_id = %s
                  AND e.event_date >= CURRENT_DATE
            ) AS upcoming_event_count,

            (
                SELECT COUNT(*)
                FROM expense x
                JOIN event_club ec
                    ON ec.event_id = x.event_id
                WHERE ec.club_id = %s
                  AND x.approved_by IS NULL
            ) AS pending_expense_count
        """,
        (club_id, club_id, club_id, club_id, club_id),
        one=True
    )

    upcoming_events = query(
        """
        SELECT
            e.event_id,
            e.name,
            e.event_date,
            e.venue,
            e.capacity
        FROM event e
        JOIN event_club ec
            ON ec.event_id = e.event_id
        WHERE ec.club_id = %s
          AND e.event_date >= CURRENT_DATE
        ORDER BY e.event_date, e.event_id
        LIMIT 6
        """,
        (club_id,)
    )

    return {
        "club": club,
        "stats": stats,
        "upcoming_events": upcoming_events
    }


# --------------------------------------------------
# CLUB MEMBERS
# --------------------------------------------------

def list_members(club_id):
    return query(
        """
        SELECT
            m.membership_id,
            m.roll_number,
            s.name AS student_name,
            s.department,
            s.year,
            m.position,
            t.name AS team_name

        FROM membership m

        JOIN student s
            ON s.roll_number = m.roll_number

        LEFT JOIN team t
            ON t.team_id = m.team_id
           AND t.club_id = m.club_id

        WHERE m.club_id = %s

        ORDER BY
            CASE m.position
                WHEN 'president' THEN 1
                WHEN 'secretary' THEN 2
                WHEN 'treasurer' THEN 3
                WHEN 'lead' THEN 4
                WHEN 'core' THEN 5
                ELSE 6
            END,
            s.name
        """,
        (club_id,)
    )


def list_teams(club_id):
    return query(
        """
        SELECT team_id, name
        FROM team
        WHERE club_id = %s
        ORDER BY name
        """,
        (club_id,)
    )


# --------------------------------------------------
# CREATE CLUB EVENT
# --------------------------------------------------

def create_event(
    club_id,
    roll_number,
    name,
    event_date,
    venue,
    capacity,
    estimated,
    allotted=0
):

    # Verify officer permission
    officer = officer_membership(roll_number, club_id)

    if not officer:
        raise ValueError(
            "Your account is not an officer of this club."
        )

    # Validate event name
    if not isinstance(name, str) or not name.strip():
        raise ValueError("Event name is required.")

    # Validate event date
    if not isinstance(event_date, date):
        raise ValueError("Invalid event date.")

    if event_date < date.today():
        raise ValueError(
            "Cannot create an event with a past date."
        )

    # Validate capacity
    if capacity is not None:
        if isinstance(capacity, bool) or not isinstance(capacity, int):
            raise ValueError("Capacity must be a whole number.")

        if capacity <= 0:
            raise ValueError(
                "Capacity must be a positive number."
            )

    # Validate estimated budget
    try:
        estimated = Decimal(str(estimated))
    except (InvalidOperation, ValueError, TypeError):
        raise ValueError("Invalid estimated budget.")

    if not estimated.is_finite() or estimated < 0:
        raise ValueError(
            "Estimated budget must be a non-negative amount."
        )

    # Security rule:
    # Officers cannot allot budgets.
    # The 'allotted' argument is retained for compatibility
    # with the existing Flask route, but is ignored.
    allotted = Decimal("0")

    # Create event, club association and budget
    # in one database transaction.
    with connect() as conn:
        with conn.cursor() as cur:

            # Create event without coordinator first
            cur.execute(
                """
                INSERT INTO event
                    (
                        name,
                        event_date,
                        venue,
                        capacity,
                        coordinator_id
                    )
                VALUES (%s, %s, %s, %s, NULL)
                RETURNING event_id
                """,
                (
                    name.strip(),
                    event_date,
                    venue.strip() if isinstance(venue, str) and venue.strip() else None,
                    capacity
                )
            )

            event_id = cur.fetchone()[0]

            # Associate event with club
            cur.execute(
                """
                INSERT INTO event_club
                    (event_id, club_id)
                VALUES (%s, %s)
                """,
                (event_id, club_id)
            )

            # Assign coordinator after club association
            cur.execute(
                """
                UPDATE event
                SET coordinator_id = %s
                WHERE event_id = %s
                """,
                (
                    officer["membership_id"],
                    event_id
                )
            )

            # Officer can estimate, but cannot allot
            cur.execute(
                """
                INSERT INTO budget
                    (event_id, estimated, allotted)
                VALUES (%s, %s, %s)
                """,
                (
                    event_id,
                    estimated,
                    allotted
                )
            )

    return event_id


# --------------------------------------------------
# EXPENSE DETAILS
# --------------------------------------------------

def expense_data(club_id):

    pending = query(
        """
        SELECT
            x.expense_id,
            x.event_id,
            ev.name AS event_name,
            x.description,
            x.amount,
            x.spent_on

        FROM expense x

        JOIN event ev
            ON ev.event_id = x.event_id

        JOIN event_club ec
            ON ec.event_id = x.event_id

        WHERE ec.club_id = %s
          AND x.approved_by IS NULL

        ORDER BY
            x.spent_on DESC,
            x.expense_id DESC
        """,
        (club_id,)
    )

    history = query(
        """
        SELECT
            x.expense_id,
            x.event_id,
            ev.name AS event_name,
            x.description,
            x.amount,
            x.spent_on,
            x.approved_by,
            approver.roll_number AS approver_roll

        FROM expense x

        JOIN event ev
            ON ev.event_id = x.event_id

        JOIN event_club ec
            ON ec.event_id = x.event_id

        LEFT JOIN membership approver
            ON approver.membership_id = x.approved_by

        WHERE ec.club_id = %s
          AND x.approved_by IS NOT NULL

        ORDER BY
            x.spent_on DESC,
            x.expense_id DESC

        LIMIT 30
        """,
        (club_id,)
    )

    return {
        "pending": pending,
        "history": history
    }


# --------------------------------------------------
# APPROVE EXPENSE
# --------------------------------------------------

def approve_expense(club_id, roll_number, expense_id):
    officer = _membership(roll_number, club_id)

    if not officer or officer["position"] not in APPROVER_POSITIONS:
        raise ValueError(
            "Only a treasurer, lead, or core member can approve expenses."
        )

    # All checks and the update occur in one transaction.
    with connect() as conn:
        with conn.cursor() as cur:
            # Locate the expense and verify its club. No modification yet.
            cur.execute(
                """
                SELECT x.event_id
                FROM expense x
                JOIN event_club ec ON ec.event_id = x.event_id
                WHERE x.expense_id = %s
                  AND ec.club_id = %s
                  AND x.approved_by IS NULL
                """,
                (expense_id, club_id)
            )
            row = cur.fetchone()
            if not row:
                raise ValueError(
                    "That expense is not pending for this club, "
                    "or it was already processed."
                )
            event_id = row[0]

            # Serialize approvals for the same event by locking its budget.
            cur.execute(
                "SELECT allotted FROM budget WHERE event_id = %s FOR UPDATE",
                (event_id,)
            )
            budget_row = cur.fetchone()
            if not budget_row:
                raise ValueError("No budget exists for this event.")
            allotted = budget_row[0] or Decimal("0")

            # Recheck after acquiring the budget lock: another approval may
            # have completed while this transaction was waiting.
            cur.execute(
                """
                SELECT x.amount
                FROM expense x
                WHERE x.expense_id = %s
                  AND x.event_id = %s
                  AND x.approved_by IS NULL
                FOR UPDATE
                """,
                (expense_id, event_id)
            )
            expense_row = cur.fetchone()
            if not expense_row:
                raise ValueError(
                    "That expense is not pending for this club, "
                    "or it was already processed."
                )
            amount = expense_row[0]

            cur.execute(
                """
                SELECT COALESCE(SUM(amount), 0)
                FROM expense
                WHERE event_id = %s
                  AND approved_by IS NOT NULL
                """,
                (event_id,)
            )
            approved_total = cur.fetchone()[0]

            if approved_total + amount > allotted:
                remaining = allotted - approved_total
                raise ValueError(
                    f"Insufficient allotted budget. Remaining: {remaining}; "
                    f"expense amount: {amount}."
                )

            cur.execute(
                """
                UPDATE expense
                SET approved_by = %s
                WHERE expense_id = %s
                  AND event_id = %s
                  AND approved_by IS NULL
                """,
                (officer["membership_id"], expense_id, event_id)
            )
            if cur.rowcount != 1:
                raise ValueError("Expense approval could not be completed.")

    return 1


# --------------------------------------------------
# CLUB BUDGETS
# --------------------------------------------------

def budget_data(club_id):

    rows = query(
        """
        SELECT
            e.event_id,
            e.name AS event_name,
            e.event_date,
            b.estimated,
            b.allotted,

            COALESCE(
                (
                    SELECT SUM(x.amount)
                    FROM expense x
                    WHERE x.event_id = e.event_id
                      AND x.approved_by IS NOT NULL
                ),
                0
            ) AS spent,

            (
                SELECT COUNT(*)
                FROM expense x
                WHERE x.event_id = e.event_id
                  AND x.approved_by IS NULL
            ) AS pending_expenses

        FROM event e

        JOIN event_club ec
            ON ec.event_id = e.event_id

        LEFT JOIN budget b
            ON b.event_id = e.event_id

        WHERE ec.club_id = %s

        ORDER BY
            e.event_date DESC,
            e.event_id DESC
        """,
        (club_id,)
    )

    totals = {
        "estimated": sum(
            (r["estimated"] or 0) for r in rows
        ),
        "allotted": sum(
            (r["allotted"] or 0) for r in rows
        ),
        "spent": sum(
            (r["spent"] or 0) for r in rows
        )
    }

    return {
        "rows": rows,
        "totals": totals
    }


# --------------------------------------------------
# CLUB ANALYSIS
# --------------------------------------------------

def club_analysis(club_id):

    # Only active or attended registrations
    # are counted as participation.
    return query(
        """
        SELECT

            (
                SELECT COUNT(*)
                FROM event_club ec
                WHERE ec.club_id = %s
            ) AS events_organized,

            (
                SELECT COUNT(DISTINCT er.event_id)
                FROM event_registration er
                JOIN event_club ec
                    ON ec.event_id = er.event_id
                WHERE ec.club_id = %s
                  AND er.status IN ('registered', 'attended')
            ) AS events_with_participants,

            (
                SELECT COUNT(*)
                FROM event_registration er
                JOIN event_club ec
                    ON ec.event_id = er.event_id
                WHERE ec.club_id = %s
                  AND er.status IN ('registered', 'attended')
            ) AS total_registrations,

            (
                SELECT COUNT(DISTINCT er.roll_number)
                FROM event_registration er
                JOIN event_club ec
                    ON ec.event_id = er.event_id
                WHERE ec.club_id = %s
                  AND er.status IN ('registered', 'attended')
            ) AS unique_participants,

            (
                SELECT COUNT(*)
                FROM event_club ec
                JOIN event e
                    ON e.event_id = ec.event_id
                WHERE ec.club_id = %s
                  AND e.event_date >= CURRENT_DATE
            ) AS upcoming_events,

            (
                SELECT COUNT(*)
                FROM membership
                WHERE club_id = %s
            ) AS total_members,

            (
                SELECT COUNT(*)
                FROM team
                WHERE club_id = %s
            ) AS total_teams
        """,
        (
            club_id,
            club_id,
            club_id,
            club_id,
            club_id,
            club_id,
            club_id
        ),
        one=True
    )
