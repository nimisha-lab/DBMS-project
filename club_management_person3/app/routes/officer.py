from datetime import date
import psycopg2
from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.auth import officer_required, current_user
from app.db import db_error_message, query
from app.services.officer import (
    dashboard_data, list_members, list_teams, create_event,
    expense_data, approve_expense, budget_data, club_analysis
)

bp = Blueprint("officer", __name__, url_prefix="/officer")

@bp.get("/<int:club_id>/dashboard")
@officer_required
def dashboard(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    return render_template("officer/dashboard.html", **data)

@bp.get("/<int:club_id>/members")
@officer_required
def members(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    return render_template("officer/members.html",
                           club=data["club"], members=list_members(club_id))

@bp.route("/<int:club_id>/events/new", methods=["GET", "POST"])
@officer_required
def new_event(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    if request.method == "POST":
        try:
            name = request.form.get("name", "")
            event_date = date.fromisoformat(request.form.get("event_date", ""))
            venue = request.form.get("venue", "")
            capacity_raw = request.form.get("capacity", "").strip()
            capacity = int(capacity_raw) if capacity_raw else None
            estimated = float(request.form.get("estimated", "0"))
            allotted = float(request.form.get("allotted", "0"))
            event_id = create_event(
                club_id, current_user()["roll_number"], name, event_date,
                venue, capacity, estimated, allotted
            )
            flash(f"Event created successfully (ID: {event_id}).", "success")
            return redirect(url_for("officer.dashboard", club_id=club_id))
        except (ValueError, TypeError) as exc:
            flash(str(exc) or "Please enter valid event details.", "error")
        except psycopg2.Error as exc:
            flash(db_error_message(exc), "error")
    return render_template("officer/new_event.html", club=data["club"], today=date.today().isoformat())

@bp.get("/<int:club_id>/expenses")
@officer_required
def expenses(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    user = current_user()
    role_row = query(
        "SELECT position FROM membership WHERE roll_number=%s AND club_id=%s",
        (user["roll_number"], club_id), one=True
    )
    role = role_row["position"] if role_row else None
    return render_template("officer/expenses.html", club=data["club"],
                           data=expense_data(club_id),
                           can_approve=role in ("treasurer", "lead", "core"))

@bp.post("/<int:club_id>/expenses/<int:expense_id>/approve")
@officer_required
def approve(club_id, expense_id):
    try:
        approve_expense(club_id, current_user()["roll_number"], expense_id)
        flash("Expense approved.", "success")
    except ValueError as exc:
        flash(str(exc), "error")
    except psycopg2.Error as exc:
        flash(db_error_message(exc), "error")
    return redirect(url_for("officer.expenses", club_id=club_id))


@bp.get("/<int:club_id>/budgets")
@officer_required
def budgets(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    return render_template("officer/budgets.html", club=data["club"],
                           data=budget_data(club_id))


@bp.get("/<int:club_id>/analysis")
@officer_required
def analysis(club_id):
    data = dashboard_data(club_id)
    if not data:
        flash("Club not found.", "error")
        return redirect(url_for("student.events"))
    return render_template("officer/analysis.html", club=data["club"],
                           stats=club_analysis(club_id))
