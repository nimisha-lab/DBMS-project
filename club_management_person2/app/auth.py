from functools import wraps
from flask import session,redirect,url_for,flash
from app.db import query
def current_user():
    uid=session.get('user_id')
    if not uid: return None
    u=query('SELECT ua.user_id,ua.roll_number,ua.is_admin,s.name FROM user_account ua LEFT JOIN student s ON s.roll_number=ua.roll_number WHERE ua.user_id=%s',(uid,),True)
    if not u: session.clear(); return None
    rows=[] if u['is_admin'] else query("SELECT DISTINCT club_id FROM membership WHERE roll_number=%s AND position IN ('president','secretary','treasurer','lead','core') ORDER BY club_id",(u['roll_number'],))
    u['officer_clubs']=[r['club_id'] for r in rows]
    return u
def login_required(fn):
    @wraps(fn)
    def w(*a,**k):
        if not current_user(): flash('Please log in.','notice'); return redirect(url_for('public.login'))
        return fn(*a,**k)
    return w
def officer_required(fn):
    @wraps(fn)
    def w(*a,**k):
        u=current_user()
        if not u: flash('Please log in.','notice'); return redirect(url_for('public.login'))
        if u['is_admin'] or k.get('club_id') not in u['officer_clubs']: flash('Officer access required for this club.','error'); return redirect(url_for('student.events'))
        return fn(*a,**k)
    return w
def admin_required(fn):
    @wraps(fn)
    def w(*a,**k):
        u=current_user()
        if not u: flash('Please log in.','notice'); return redirect(url_for('public.login'))
        if not u['is_admin']: flash('Administrator access required.','error'); return redirect(url_for('student.events'))
        return fn(*a,**k)
    return w
