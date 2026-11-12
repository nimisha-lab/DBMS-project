# Create 50 student logins and one admin login after schema and seed.
import os
import sys
import psycopg2
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv()
CONFIG = dict(
    dbname=os.getenv("DB_NAME", "club_management_db"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD", ""),
    host=os.getenv("DB_HOST", "localhost"),
    port=os.getenv("DB_PORT", "5432"),
)
DEMO_PASSWORD = os.getenv("DEMO_PASSWORD", "ClubDemo@2026")

def main():
    try:
        hashed = generate_password_hash(DEMO_PASSWORD)
        with psycopg2.connect(**CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM user_account")
                cur.execute("""
                    INSERT INTO user_account(user_id,roll_number,password_hash,is_admin)
                    SELECT roll_number,roll_number,%s,FALSE FROM student
                    ORDER BY roll_number
                """, (hashed,))
                cur.execute("""
                    INSERT INTO user_account(user_id,roll_number,password_hash,is_admin)
                    VALUES ('admin',NULL,%s,TRUE)
                """, (hashed,))
                cur.execute("SELECT COUNT(*) FROM user_account")
                total = cur.fetchone()[0]
        print(f"Created {total} demo accounts.")
        print("Student IDs: S001 through S050; administrator ID: admin.")
        print("Password: the value configured in DEMO_PASSWORD.")
    except psycopg2.Error as exc:
        detail = getattr(getattr(exc, "diag", None), "message_primary", None)
        print("Database error:", detail or str(exc))
        sys.exit(1)

if __name__ == "__main__":
    main()
