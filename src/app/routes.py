from flask import Blueprint, jsonify
from app.models import db, Vehicle

bp = Blueprint('main', __name__)

@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@bp.route('/vehicles')
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
def get_vehicle(vehicle_id):
    """Get specific vehicle by ID"""
    try:
        vehicle = Vehicle.query.get_or_404(vehicle_id)
        return jsonify(vehicle.to_dict())
    except Exception as e:
        return jsonify({'error': str(e)}), 500