from flask import Blueprint, jsonify, request
from app.models import db, Vehicle
from app.auth import token_required, generate_token, authenticate_user

bp = Blueprint('main', __name__)

@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@bp.route('/login', methods=['POST'])
def login():
    """Authenticate user and return JWT token"""
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({'error': 'Username and password required'}), 400
            
        if authenticate_user(username, password):
            token = generate_token(username)
            return jsonify({'token': token})
        else:
            return jsonify({'error': 'Invalid credentials'}), 401
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/vehicles')
@token_required
def get_vehicles():
    """Get all vehicles from catalog"""
    try:
        vehicles = Vehicle.query.all()
        return jsonify({
            'vehicles': [vehicle.to_dict() for vehicle in vehicles],
            'count': len(vehicles)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/vehicles/<int:vehicle_id>')
@token_required
def get_vehicle(vehicle_id):
    """Get specific vehicle by ID"""
    try:
        vehicle = Vehicle.query.get_or_404(vehicle_id)
        return jsonify(vehicle.to_dict())
    except Exception as e:
        return jsonify({'error': str(e)}), 500