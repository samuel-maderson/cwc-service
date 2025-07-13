import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
    ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')

class DevelopmentConfig(Config):
    DEBUG = True
    SECRET_NAME = 'rds-db-credentials/cwc-db-cluster-dev/master'
    DATABASE_NAME = 'cwc_catalog'

class ProductionConfig(Config):
    DEBUG = False
    SECRET_NAME = 'rds-db-credentials/cwc-db-cluster/master'
    DATABASE_NAME = 'cwc_catalog'

config = {
    'dev': DevelopmentConfig,
    'prod': ProductionConfig,
    'default': DevelopmentConfig
}