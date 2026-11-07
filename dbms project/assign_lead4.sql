-- Club 10 (Curiosity, cultural): lead - change S036 from member to lead
UPDATE membership SET position = 'lead' WHERE roll_number = 'S036' AND club_id = 10;