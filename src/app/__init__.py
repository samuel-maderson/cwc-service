import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from config.settings import config
from app.secrets import get_db_credentials

def create_app(config_name=None):
    """Create and configure Flask application with database and routes"""
    app = Flask(__name__)
    
    config_name = config_name or app.config.get('ENVIRONMENT', 'default')
    app_config = config[config_name]
    app.config.from_object(app_config)
    
    print(f"DEBUG: Environment: {os.getenv('ENVIRONMENT')}")
    print(f"DEBUG: RDS Endpoint: {os.getenv('RDS_ENDPOINT')}")
    print(f"DEBUG: Secret Name: {app_config.SECRET_NAME}")
    
    # Database connection with error handling
    try:
        db_creds = get_db_credentials(app_config)
        database_uri = f"mysql+pymysql://{db_creds['username']}:{db_creds['password']}@{db_creds['host']}:{db_creds['port']}/{db_creds['database']}"
        print(f"DEBUG: Database URI: mysql+pymysql://{db_creds['username']}:***@{db_creds['host']}:{db_creds['port']}/{db_creds['database']}")
        app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
        app.config['DB_CONNECTION_ERROR'] = False
    except Exception as e:
        print(f"ERROR: Database connection failed: {str(e)}")
        print("WARNING: API will run without database functionality")
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'  # Fallback
        app.config['DB_CONNECTION_ERROR'] = True
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    from app.models import db
    db.init_app(app)
    migrate = Migrate(app, db)
    
    from app.routes import bp as main_bp
    from app.health import health_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(health_bp)
    
    return app