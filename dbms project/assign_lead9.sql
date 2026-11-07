-- Club 8 (cs club, technical): lead - change S038 from member to lead
UPDATE membership SET position = 'lead' WHERE roll_number = 'S038' AND club_id = 8;