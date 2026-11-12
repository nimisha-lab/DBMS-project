"""Create missing student and admin logins without changing existing accounts."""
import os
import sys

import psycopg2
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv()
CONFIG = dict(
    dbname=os.getenv("DB_NAME", "club_management_database"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD", ""),
    host=os.getenv("DB_HOST", "localhost"),
    port=os.getenv("DB_PORT", "5432"),
)
DEMO_PASSWORD = os.getenv("DEMO_PASSWORD", "ClubDemo@2026")


def main():
    try:
        with psycopg2.connect(**CONFIG) as conn:
            with conn.cursor() as cur:
                # Guard against accidentally targeting the wrong database.
                cur.execute("SELECT current_database()")
                db_name = cur.fetchone()[0]
                if db_name != "club_management_database":
                    raise ValueError(f"Unexpected database: {db_name}")

                hashed = generate_password_hash(DEMO_PASSWORD)
                cur.execute("""
                    INSERT INTO user_account (user_id, roll_number, password_hash, is_admin)
                    SELECT s.roll_number, s.roll_number, %s, FALSE
                    FROM student AS s
                    WHERE s.roll_number BETWEEN 'S001' AND 'S050'
                    ON CONFLICT DO NOTHING
                """, (hashed,))
                student_created = cur.rowcount

                cur.execute("""
                    INSERT INTO user_account (user_id, roll_number, password_hash, is_admin)
                    VALUES ('admin', NULL, %s, TRUE)
                    ON CONFLICT DO NOTHING
                """, (hashed,))
                admin_created = cur.rowcount

                cur.execute("SELECT COUNT(*) FROM user_account")
                total = cur.fetchone()[0]

        print(f"Database: {db_name}")
        print(f"New student accounts: {student_created}")
        print(f"New admin accounts: {admin_created}")
        print(f"Total accounts: {total}")
        print("Existing accounts and password hashes were not modified.")
        if student_created or admin_created:
            print("New accounts use the password configured by DEMO_PASSWORD.")
    except (psycopg2.Error, ValueError) as exc:
        print(f"Account initialization failed: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
