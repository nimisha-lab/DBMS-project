# Person 2 Flask implementation

Copy `app/` and `run.py` into the repository root. If `app/` already exists,
merge only the Person 2 files; do not overwrite Person 3 officer files.

Install: `py -m pip install flask psycopg2-binary python-dotenv werkzeug`
Use Person 1's `.env.example` to create `.env`; set DB_PASSWORD and SECRET_KEY.
Confirm Person 1 has run reset and that `user_account` and `v_recent_announcements`
exist. Start with `py run.py`; open http://127.0.0.1:5000.

Student IDs: S001-S050; admin ID: admin. Use the team's shared demo password.

Contract helpers: query, execute, db_error_message; current_user,
login_required, officer_required, admin_required. Contract service functions:
list_events, register, cancel_registration, my_registrations, my_clubs,
join_club, leave_club, recent_announcements.

Contract URLs: /login, /logout, /events, /events/<id>/register (POST),
/events/<id>/cancel (POST), /my/clubs, /my/clubs/join (POST),
/my/clubs/<club_id>/leave (POST), /announcements. Extra page: /my/registrations.

The implementation uses event_registration's composite key
(event_id, roll_number), validates team/club ownership, and only lets ordinary
members leave through the student route. Database errors propagate from
services and are caught by routes. This pack has not yet been tested against
your local PostgreSQL database.
