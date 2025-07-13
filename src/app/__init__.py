from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from config.settings import config
from app.secrets import get_db_credentials

def create_app(config_name=None):
    app = Flask(__name__)
    
    # Load configuration
    config_name = config_name or app.config.get('ENVIRONMENT', 'default')
    app.config.from_object(config[config_name])
    
    # Get database credentials
    try:
        db_creds = get_db_credentials(config[config_name])
        database_uri = f"mysql+pymysql://{db_creds['username']}:{db_creds['password']}@{db_creds['host']}:{db_creds['port']}/{db_creds['database']}"
        app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
    except Exception as e:
        app.logger.error(f"Failed to get database credentials: {e}")
        # Fallback for local development
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///fallback.db'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # Initialize extensions
    from app.models import db
    db.init_app(app)
    migrate = Migrate(app, db)
    
    # Register blueprints
    from app.routes import bp as main_bp
    app.register_blueprint(main_bp)
    
    return app