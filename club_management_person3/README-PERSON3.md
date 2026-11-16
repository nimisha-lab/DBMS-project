# Person 3 — Club Lead / Officer module

This package is an add-on to Person 2's Flask application. It implements only club-specific officer features. It does not implement the admin dashboard, global budget approval, admin event creation, or analysis across all clubs.

## Routes
- `/officer/<club_id>/dashboard` — club dashboard and upcoming events
- `/officer/<club_id>/members` — club members, team names and positions
- `/officer/<club_id>/events/new` — create an event for this club and add its budget record
- `/officer/<club_id>/expenses` — view pending/approved expenses; approve when role permits
- `/officer/<club_id>/budgets` — view this club's event budgets and expense totals
- `/officer/<club_id>/analysis` — club-only metrics: events organized, registrations, unique participants, upcoming events, members and teams

## Install / integrate
Copy the `app/routes/officer.py`, `app/services/officer.py`, and `app/templates/officer/` folder into the existing Person 2 project. Merge files if they already exist; do not overwrite Person 1 or Person 2 files.

In `app/__init__.py`, add `from app.routes.officer import bp as officer_bp` and register it inside `create_app()` using `app.register_blueprint(officer_bp)`. Keep the existing blueprints.

The existing Person 2 `base.html` already exposes student navigation (Events, My clubs, My registrations, Announcements), so those shared student features remain available to officers without duplicating Person 2 pages.

## Database columns used
Uses the team's existing schema names: `club.club_id/name/type`, `team.team_id/club_id/name`, `membership.membership_id/roll_number/club_id/team_id/position`, `student.roll_number/name/department/year`, `event.event_id/name/event_date/venue/capacity/coordinator_id`, `event_club.event_id/club_id`, `event_registration.event_id/roll_number`, `budget.event_id/estimated/allotted`, and `expense.expense_id/event_id/description/amount/spent_on/approved_by`. No SQL/schema changes are included.

## Permissions
All routes use Person 2's `@officer_required` helper and are scoped to clubs where the signed-in user is an officer. Expense approval remains limited to `treasurer`, `lead`, or `core`, matching the database trigger described in the existing implementation. Budget viewing is read-only; approval remains with Person 1's admin module.

## Validation
Python syntax is checked during packaging. This package has not been tested against your live PostgreSQL database or in a browser.
