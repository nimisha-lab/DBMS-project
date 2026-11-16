from app.db import query,execute
def my_clubs(roll):
    return query('SELECT m.membership_id,m.club_id,c.name AS club_name,c.type,m.position,m.team_id,t.name AS team_name FROM membership m JOIN club c ON c.club_id=m.club_id LEFT JOIN team t ON t.team_id=m.team_id AND t.club_id=m.club_id WHERE m.roll_number=%s ORDER BY c.name',(roll,))
def available_clubs(roll):
    return query('SELECT c.club_id,c.name,c.type FROM club c WHERE NOT EXISTS(SELECT 1 FROM membership m WHERE m.club_id=c.club_id AND m.roll_number=%s) ORDER BY c.name',(roll,))
def teams_for_club(cid):
    return query('SELECT team_id,name FROM team WHERE club_id=%s ORDER BY name',(cid,))
def join_club(roll,cid,tid=None):
    if not query('SELECT club_id FROM club WHERE club_id=%s',(cid,),True): raise ValueError('The selected club does not exist.')
    if tid in ('',None): tid=None
    elif not query('SELECT team_id FROM team WHERE team_id=%s AND club_id=%s',(tid,cid),True): raise ValueError('Choose a team belonging to the selected club.')
    if query('SELECT membership_id FROM membership WHERE roll_number=%s AND club_id=%s',(roll,cid),True): raise ValueError('You are already a member of this club.')
    execute("INSERT INTO membership(roll_number,club_id,team_id,position) VALUES(%s,%s,%s,'member')",(roll,cid,tid))
def leave_club(roll,cid):
    n=execute("DELETE FROM membership WHERE roll_number=%s AND club_id=%s AND position='member'",(roll,cid))
    if not n: raise ValueError('Only ordinary members can leave from the student page.')
