import os
from app import create_app

app = create_app(os.getenv('ENVIRONMENT', 'default'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=app.config['DEBUG'])