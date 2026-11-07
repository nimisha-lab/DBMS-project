-- Club 3 (system coding club, technical): core - change S032 from member to core
UPDATE membership SET position = 'core' WHERE roll_number = 'S032' AND club_id = 3;