
import os
from pathlib import Path

from flask import Flask
from dotenv import load_dotenv

from app.routes.public import bp as public_bp
from app.routes.student import bp as student_bp
from app.routes.officer import bp as officer_bp

load_dotenv(
    Path(__file__).resolve().parents[1] / ".env",
    override=True
)


def create_app():
    app = Flask(__name__)

    app.config["SECRET_KEY"] = os.getenv(
        "SECRET_KEY", "change-this-secret"
    )

    app.register_blueprint(public_bp)
    app.register_blueprint(student_bp)
    app.register_blueprint(officer_bp)

    return app
