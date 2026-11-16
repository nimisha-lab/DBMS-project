from flask import Blueprint,render_template,request,redirect,url_for,flash,session
from werkzeug.security import check_password_hash
import psycopg2
from app.db import query,db_error_message
from app.auth import current_user
from app.services.events import list_events,recent_announcements
bp=Blueprint('public',__name__)
@bp.route('/')
def home(): return redirect(url_for('student.events')) if current_user() else redirect(url_for('public.login'))
@bp.route('/login',methods=['GET','POST'])
def login():
    if request.method=='POST':
        try:
            u=query('SELECT user_id,password_hash FROM user_account WHERE user_id=%s',(request.form.get('user_id','').strip(),),True)
            if u and check_password_hash(u['password_hash'],request.form.get('password','')):
                session.clear(); session['user_id']=u['user_id']; flash('You are now logged in.','success'); return redirect(url_for('student.events'))
            flash('Invalid user ID or password.','error')
        except psycopg2.Error as e: flash(db_error_message(e),'error')
    return render_template('public/login.html')
@bp.route('/logout',methods=['POST'])
def logout(): session.clear(); flash('You have been logged out.','success'); return redirect(url_for('public.login'))
@bp.route('/announcements')
def announcements():
    try: rows=recent_announcements()
    except psycopg2.Error as e: flash(db_error_message(e),'error'); rows=[]
    return render_template('public/announcements.html',announcements=rows)
@bp.route('/public-events')
def public_events():
    try: rows=list_events()
    except psycopg2.Error as e: flash(db_error_message(e),'error'); rows=[]
    return render_template('public/events.html',events=rows)
