import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import inspect

db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
        "DATABASE_URI", "sqlite:///flask_app.db"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
        "pool_pre_ping": True,
        "connect_args": {"check_same_thread": False}
    }

    db.init_app(app)

    # Health endpoint
    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    with app.app_context():
        db.create_all()
        # Lightweight migration for username column
        try:
            inspector = inspect(db.engine)
            columns = [col["name"] for col in inspector.get_columns("sessions")]
            if "username" not in columns:
                with db.engine.connect() as conn:
                    conn.execute(db.text("ALTER TABLE sessions ADD COLUMN username VARCHAR(255)"))
                    conn.commit()
        except Exception:
            # Ignore if fails (e.g., not SQLite or already exists)
            pass

    return app