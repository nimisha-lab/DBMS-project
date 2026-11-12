-- Club 4 (developers club, technical): core - change S035 from member to core
UPDATE membership SET position = 'core' WHERE roll_number = 'S035' AND club_id = 4;