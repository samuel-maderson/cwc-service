import os
from dotenv import load_dotenv
from app.secrets import get_secret

load_dotenv()

def get_jwt_secret():
    """Get JWT secret from Secrets Manager"""
    secret_name = os.getenv('API_AUTH_SECRET_NAME')
    if not secret_name:
        raise ValueError('API_AUTH_SECRET_NAME environment variable not set')
    
    secret = get_secret(secret_name, os.getenv('AWS_REGION', 'us-east-1'))
    return secret['jwt_secret_key']

class Config:
    SECRET_KEY = get_jwt_secret()
    AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
    ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')

class DevelopmentConfig(Config):
    DEBUG = True
    SECRET_NAME = os.environ.get('SECRET_NAME')
    DATABASE_NAME = 'cwc_catalog'

class ProductionConfig(Config):
    DEBUG = False
    SECRET_NAME = os.environ.get('SECRET_NAME')
    DATABASE_NAME = 'cwc_catalog'

config = {
    'dev': DevelopmentConfig,
    'prod': ProductionConfig,
    'default': DevelopmentConfig
}