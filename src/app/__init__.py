import subprocess
import json
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from config.settings import config
from app.secrets import get_db_credentials

def get_terraform_output(output_name):
    """Get terraform output value"""
    try:
        result = subprocess.run(
            ['terraform', 'output', '-raw', output_name],
            cwd='../infrastructure',
            capture_output=True,
            text=True
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except:
        return None

def create_app(config_name=None):
    """Create and configure Flask application with database and routes"""
    app = Flask(__name__)
    
    config_name = config_name or app.config.get('ENVIRONMENT', 'default')
    app_config = config[config_name]
    app.config.from_object(app_config)
    
    try:
        secret_name = get_terraform_output('rds_dev_secret_name')
        if secret_name and secret_name != 'null':
            app_config.SECRET_NAME = secret_name
        
        db_creds = get_db_credentials(app_config)
        database_uri = f"mysql+pymysql://{db_creds['username']}:{db_creds['password']}@{db_creds['host']}:{db_creds['port']}/{db_creds['database']}"
        app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
    except Exception as e:
        app.logger.error(f"Failed to get database credentials: {e}")
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///fallback.db'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    from app.models import db
    db.init_app(app)
    migrate = Migrate(app, db)
    
    from app.routes import bp as main_bp
    app.register_blueprint(main_bp)
    
    return app