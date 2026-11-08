CREATE TABLE IF NOT EXISTS user_account (
    user_id VARCHAR(20) PRIMARY KEY,
    roll_number VARCHAR(12) UNIQUE REFERENCES student(roll_number) ON DELETE CASCADE,
    password_hash TEXT NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_account_identity CHECK (
        (is_admin AND roll_number IS NULL AND user_id = 'admin')
        OR (NOT is_admin AND roll_number IS NOT NULL AND user_id = roll_number)
    )
);
CREATE INDEX IF NOT EXISTS idx_user_account_roll ON user_account(roll_number);
