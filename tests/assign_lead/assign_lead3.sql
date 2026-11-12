-- Club 9 (footlights, cultural): lead - change S034 from member to lead
UPDATE membership SET position = 'lead' WHERE roll_number = 'S034' AND club_id = 9;