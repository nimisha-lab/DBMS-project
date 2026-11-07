-- Club 6 (ASTRA, technical_team): core - change S042 from member to core
UPDATE membership SET position = 'core' WHERE roll_number = 'S042' AND club_id = 6;