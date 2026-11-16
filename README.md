# Club Management System

A PostgreSQL-backed web application for managing student clubs, teams, memberships, events, registrations, announcements, and event finances. Built as a DBMS project with a Flask interface and database-enforced business rules.

## Overview

The repository combines a relational database implementation with a student-facing web application and club-scoped officer tools. The integrated, runnable Flask application is in [`club_management_person2/`](club_management_person2/). [`club_management_person3/`](club_management_person3/) retains a separate copy of the officer module; **run the integrated application, not the standalone module**.

### Implemented features

| Area | Functionality |
| --- | --- |
| Public | Login; view announcements and public event listings |
| Students | Browse upcoming events; register, cancel, and view registrations; view, join, and leave eligible clubs and teams |
| Club officers | Club dashboard; members and teams; event creation with estimated budget; pending and approved expenses; club budgets and analytics |
| Expense approvals | Eligible club officers (`treasurer`, `lead`, `core`) can approve pending expenses, subject to authorization and budget checks |
| Database | Keys, checks, foreign keys, indexes, views, functions, triggers, membership history, and expense audit records |

**Scope:** The repository defines an admin account and an `admin_required` helper, but the integrated Flask application does not register an admin dashboard or global budget-allotment interface. An officer can enter an **estimated** event budget, but cannot allot funds: the event creation service initializes `budget.allotted` to `0`.

## Technology

- **Backend:** Python, Flask, Werkzeug sessions/password hashing
- **Database:** PostgreSQL, PL/pgSQL, `psycopg2-binary`
- **Frontend:** Jinja2-rendered HTML templates
- **Configuration:** `python-dotenv`

## Repository layout

```text
DBMS-project/
├── sql/
│   ├── schema.sql                 # Core relational tables and indexes
│   ├── seed.sql                   # Sample database records
│   ├── 01_user_account.sql        # Login-account table
│   ├── 02_triggers_fixed.sql      # Base integrity triggers
│   ├── 03_functions.sql           # approve_expense() function
│   ├── 04_views.sql               # Reporting/public views
│   └── 05_validation_tests.sql    # Integrity checks
├── scripts/
│   └── create_accounts_safe.py   # Creates missing demo logins only
├── club_management_person2/      # Integrated, runnable Flask app
│   ├── app/
│   │   ├── routes/               # public.py, student.py, officer.py
│   │   ├── services/             # clubs.py, events.py, officer.py
│   │   ├── templates/            # public/, student/, officer/
│   │   ├── auth.py
│   │   ├── db.py
│   │   └── __init__.py
│   ├── run.py
│   ├── requirements.txt
│   ├── strict_expense_approval.sql
│   ├── strict_budget_update.sql
│   └── test_budget_security.py
├── club_management_person3/      # Standalone officer-module source
├── tests/                        # SQL test cases
├── archive/                      # Older SQL and setup artifacts
├── initialize_safe.bat           # Adds functions, views, missing accounts
└── reset.bat                     # Legacy destructive reset; see warning below
```

## Database design

The core schema in [`sql/schema.sql`](sql/schema.sql) defines the following entities:

| Table | Purpose |
| --- | --- |
| `student`, `student_email` | Student profiles and multiple email addresses |
| `club`, `team` | Clubs and their constituent teams |
| `membership` | Student-to-club membership, team assignment, and position |
| `event`, `event_club` | Events and their organizing clubs |
| `event_registration` | Student registration status (`registered`, `attended`, `cancelled`) |
| `budget`, `expense` | Event-level estimated/allotted budgets and expense records |
| `announcement` | Club/team announcements, optionally associated with an event |
| `membership_history` | Records deleted memberships |
| `expense_audit` | JSONB snapshots of expense insertions, updates, and deletions |
| `user_account` | Login identity, hashed password, and admin flag (created separately) |

Important modeling choices:

- `membership` links students to clubs, with a unique `(roll_number, club_id)` pair and a composite team/club foreign key.
- `event_club` represents the many-to-many relationship between events and organizing clubs.
- `event_registration` uses the composite primary key `(event_id, roll_number)`.
- `budget` uses `event_id` as both its primary key and foreign key, giving each event at most one budget record.
- `expense.approved_by` references a membership record; an unapproved expense has a null approver.
- Cascading deletes, uniqueness constraints, positive-capacity/amount checks, and indexes enforce or support common operations.

### Database rules and automation

[`sql/02_triggers_fixed.sql`](sql/02_triggers_fixed.sql) defines triggers for club-type membership limits, expense-approver roles, event capacity, registration dates, membership history, expense auditing, event-coordinator club membership, and prevention of past-dated events.

[`sql/03_functions.sql`](sql/03_functions.sql) defines `approve_expense(expense_id, approver_membership_id)`. [`sql/04_views.sql`](sql/04_views.sql) provides club leadership and summary views, pending expenses, recent announcements, and public events.

The integrated application also includes **stricter** SQL rules:

- [`strict_expense_approval.sql`](club_management_person2/strict_expense_approval.sql) checks the approver's position, membership in an organizing club, and whether the total approved expenses would exceed the allotted budget. It locks the relevant budget row while checking.
- [`strict_budget_update.sql`](club_management_person2/strict_budget_update.sql) prevents lowering an allotted budget below the already approved expense total.

These stricter scripts are **not installed automatically** by `initialize_safe.bat`; they must be applied separately to a correctly initialized database. Applying the stricter expense trigger replaces the trigger function defined by the base trigger script.

## Getting started

### Prerequisites

- Python 3 with `pip`
- PostgreSQL and the `psql` command-line client
- Git (optional, for cloning)

### 1. Clone and install Python dependencies

```powershell
 git clone https://github.com/nimisha-lab/DBMS-project.git
 cd DBMS-project
 py -m venv .venv
 .\.venv\Scripts\Activate.ps1
 pip install -r club_management_person2\requirements.txt
```

On macOS/Linux, use `python3 -m venv .venv` and `source .venv/bin/activate` instead of the Windows activation command.

### 2. Configure the local database

Create a PostgreSQL database and install the schema **only on a new or disposable development database**. The commands below use the database name expected by the integrated Flask application and account-creation script:

```powershell
psql -U postgres -d postgres -c "CREATE DATABASE club_management_database;"
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f sql/schema.sql
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f sql/01_user_account.sql
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f sql/02_triggers_fixed.sql
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f sql/03_functions.sql
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f sql/04_views.sql
```

The repository includes sample data in `sql/seed.sql`. Inspect it before loading; seed scripts can conflict with existing records. On a fresh database, load it **after creating the core tables** and before creating demo user accounts. If you need the sample data, run the seed step before `scripts/create_accounts_safe.py` (and ensure the remaining SQL objects are installed as needed).

> **Do not run `reset.bat` on a database with important data.** It is destructive, and its currently committed commands reference legacy paths such as `dbms project/schema.sql` that do not match the current `sql/` layout. `initialize_safe.bat` is non-resetting, but assumes the schema and `user_account` already exist and uses a fixed database name.

### 3. Configure environment variables

Create `club_management_person2/.env` (never commit it):

```dotenv
DB_NAME=club_management_database
DB_USER=postgres
DB_PASSWORD=replace-with-your-local-password
DB_HOST=localhost
DB_PORT=5432
SECRET_KEY=replace-with-a-long-random-secret
```

`app/db.py` loads this file relative to the integrated application. The separate `scripts/create_accounts_safe.py` uses `load_dotenv()` from its execution environment, so set the same variables in your shell or provide a root-level local `.env` before running that script.

### 4. Create missing demo accounts (optional)

After the `student` and `user_account` tables exist and student seed records have been loaded, run from the repository root:

```powershell
python scripts/create_accounts_safe.py
```

The script creates missing student logins for IDs `S001`–`S050` and an `admin` login; it does not overwrite existing accounts. It reads `DEMO_PASSWORD` from the environment and otherwise uses a built-in demo default. **Set your own demo password for local testing; never reuse it for real accounts.** The script explicitly checks that the target database is `club_management_database`.

### 5. Apply stricter finance triggers (recommended for the integrated officer workflow)

Once the schema and base triggers exist:

```powershell
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f club_management_person2/strict_expense_approval.sql
psql -v ON_ERROR_STOP=1 -U postgres -d club_management_database -f club_management_person2/strict_budget_update.sql
```

Review existing finance records before applying these constraints. They enforce stricter rules on subsequent writes but do not automatically repair historical data.

### 6. Run the Flask application

```powershell
cd club_management_person2
python run.py
```

Open **http://127.0.0.1:5000**. Log in using an account in your local `user_account` table. The application is configured for local development; production deployment requires additional security and hosting configuration.

## Routes and permissions

| Route | Purpose | Access |
| --- | --- | --- |
| `/login` | Sign in | Public |
| `/public-events` | Event listing | Public |
| `/announcements` | Recent announcements | Public |
| `/events` | Upcoming events and registrations | Logged-in user |
| `/events/<event_id>/register` | Register for event (POST) | Student |
| `/events/<event_id>/cancel` | Cancel registration (POST) | Student |
| `/my/registrations` | Registration history | Student |
| `/my/clubs` | Club memberships and joining options | Student |
| `/my/clubs/join` | Join club (POST) | Student |
| `/my/clubs/<club_id>/leave` | Leave club (POST) | Ordinary club member |
| `/officer/<club_id>/dashboard` | Club dashboard | Officer of that club |
| `/officer/<club_id>/members` | Members and teams | Officer of that club |
| `/officer/<club_id>/events/new` | Create event with estimated budget | Officer of that club |
| `/officer/<club_id>/expenses` | View expenses | Officer of that club |
| `/officer/<club_id>/expenses/<expense_id>/approve` | Approve expense (POST) | Treasurer, lead, or core member of organizing club |
| `/officer/<club_id>/budgets` | Read-only budget overview | Officer of that club |
| `/officer/<club_id>/analysis` | Club-specific metrics | Officer of that club |

The app also exposes `/logout` as a POST route. Officer roles recognized by `app/auth.py` are `president`, `secretary`, `treasurer`, `lead`, and `core`; expense approval is narrower. Normal student self-service cannot remove an officer membership.

## Validation and tests

Run the database validation queries against your configured database:

```powershell
psql -U postgres -d club_management_database -f sql/05_validation_tests.sql
```

The script reports table counts, checks for capacity violations, duplicate club-type memberships, invalid expense approvers, and coordinator mismatches, and lists selected installed triggers. Its integrity-violation queries should return no rows on a consistent dataset.

A focused **mock-based** budget-security test checks that an officer's attempted allotment is ignored during event creation:

```powershell
cd club_management_person2
python test_budget_security.py
```

Additional SQL scenarios are stored under `tests/`. They are test fixtures/queries, not a complete automated integration suite. Run data-changing tests only on a disposable database.

## Known limitations

- The integrated Flask app has no implemented administrator dashboard or budget-allotment page, even though an admin identity and authorization helper exist.
- The project currently has separate integrated and standalone officer-module copies; use the integrated one to run the application.
- Some legacy setup files and archive content refer to earlier paths or database names; use the explicit setup sequence above rather than assuming every batch script is current.
  

