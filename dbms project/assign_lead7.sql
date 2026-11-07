-- Club 5 (MARS, technical_team): core - change S033 from member to core
UPDATE membership SET position = 'core' WHERE roll_number = 'S033' AND club_id = 5;