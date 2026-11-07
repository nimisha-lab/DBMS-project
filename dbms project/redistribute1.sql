-- Move S050 from club 6 (ASTRA, technical_team) to club 3 (system coding club, technical) - same type, keeps 1 membership
UPDATE membership SET club_id = 3 WHERE roll_number = 'S050';