-- Club 1 (imagix, cultural): lead - change S031 from member to lead
UPDATE membership SET position = 'lead' WHERE roll_number = 'S031' AND club_id = 1;