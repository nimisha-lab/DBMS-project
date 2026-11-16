from flask import Blueprint,render_template,request,redirect,url_for,flash
import psycopg2
from app.auth import login_required,current_user
from app.db import db_error_message
from app.services.events import list_events,register,cancel_registration,my_registrations
from app.services.clubs import my_clubs,available_clubs,teams_for_club,join_club,leave_club
bp=Blueprint('student',__name__)
def roll():
    u=current_user(); return u['roll_number'] if u else None
@bp.route('/events')
@login_required
def events():
    try:
        ev=list_events(); regs=my_registrations(roll()) if roll() else []
        active={r['event_id'] for r in regs if r['status'] in ('registered','attended')}
        return render_template('student/events.html',events=ev,active=active)
    except psycopg2.Error as e: flash(db_error_message(e),'error'); return render_template('student/events.html',events=[],active=set())
@bp.route('/events/<int:event_id>/register',methods=['POST'])
@login_required
def register_event(event_id):
    try:
        if not roll(): raise ValueError('Admin accounts cannot register as students.')
        register(roll(),event_id); flash('Your event registration was saved.','success')
    except ValueError as e: flash(str(e),'error')
    except psycopg2.Error as e: flash(db_error_message(e),'error')
    return redirect(url_for('student.events'))
@bp.route('/events/<int:event_id>/cancel',methods=['POST'])
@login_required
def cancel_event(event_id):
    try:
        if not roll(): raise ValueError('Admin accounts do not have student registrations.')
        cancel_registration(roll(),event_id); flash('Your registration has been cancelled.','success')
    except ValueError as e: flash(str(e),'error')
    except psycopg2.Error as e: flash(db_error_message(e),'error')
    return redirect(url_for('student.events'))
@bp.route('/my/clubs')
@login_required
def clubs():
    try:
        if not roll(): raise ValueError('This page is for student accounts.')
        mine=my_clubs(roll()); choices=available_clubs(roll())
        team_map={c['club_id']:teams_for_club(c['club_id']) for c in choices}
        return render_template('student/clubs.html',memberships=mine,clubs=choices,teams_by_club=team_map)
    except ValueError as e: flash(str(e),'notice'); return redirect(url_for('student.events'))
    except psycopg2.Error as e: flash(db_error_message(e),'error'); return render_template('student/clubs.html',memberships=[],clubs=[],teams_by_club={})
@bp.route('/my/clubs/join',methods=['POST'])
@login_required
def join():
    try:
        if not roll(): raise ValueError('Admin accounts cannot join clubs.')
        cid=request.form.get('club_id',type=int)
        if not cid: raise ValueError('Please choose a club.')
        join_club(roll(),cid,request.form.get('team_id',type=int)); flash('You have joined the club.','success')
    except ValueError as e: flash(str(e),'error')
    except psycopg2.Error as e: flash(db_error_message(e),'error')
    return redirect(url_for('student.clubs'))
@bp.route('/my/clubs/<int:club_id>/leave',methods=['POST'])
@login_required
def leave(club_id):
    try:
        if not roll(): raise ValueError('Admin accounts cannot leave clubs.')
        leave_club(roll(),club_id); flash('You have left the club.','success')
    except ValueError as e: flash(str(e),'error')
    except psycopg2.Error as e: flash(db_error_message(e),'error')
    return redirect(url_for('student.clubs'))
@bp.route('/my/registrations')
@login_required
def registrations():
    try:
        if not roll(): raise ValueError('This page is for student accounts.')
        rows=my_registrations(roll())
    except ValueError as e: flash(str(e),'notice'); return redirect(url_for('student.events'))
    except psycopg2.Error as e: flash(db_error_message(e),'error'); rows=[]
    return render_template('student/registrations.html',registrations=rows)
