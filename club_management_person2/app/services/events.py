from datetime import date
from app.db import query,execute
def list_events():
    return query("SELECT e.event_id,e.name,e.event_date,e.venue,e.capacity,COUNT(er.roll_number) FILTER (WHERE er.status IN ('registered','attended')) AS registered_count FROM event e LEFT JOIN event_registration er ON er.event_id=e.event_id WHERE e.event_date>=CURRENT_DATE GROUP BY e.event_id ORDER BY e.event_date,e.name")
def register(roll,event_id):
    ev=query('SELECT event_date FROM event WHERE event_id=%s',(event_id,),True)
    if not ev: raise ValueError('The selected event does not exist.')
    if ev['event_date']<date.today(): raise ValueError('Registration is closed because this event is in the past.')
    execute("INSERT INTO event_registration(event_id,roll_number,status) VALUES(%s,%s,'registered') ON CONFLICT(event_id,roll_number) DO UPDATE SET status='registered',registered_at=CURRENT_TIMESTAMP WHERE event_registration.status='cancelled'",(event_id,roll))
def cancel_registration(roll,event_id):
    n=execute("UPDATE event_registration SET status='cancelled' WHERE roll_number=%s AND event_id=%s AND status IN ('registered','attended')",(roll,event_id))
    if not n: raise ValueError('No active registration was found for this event.')
def my_registrations(roll):
    return query('SELECT e.event_id,e.name,e.event_date,e.venue,er.registered_at,er.status FROM event_registration er JOIN event e ON e.event_id=er.event_id WHERE er.roll_number=%s ORDER BY e.event_date DESC',(roll,))
def recent_announcements():
    return query('SELECT announcement_id,title,body,posted_at,club_name,team_name FROM v_recent_announcements ORDER BY posted_at DESC,announcement_id DESC')
