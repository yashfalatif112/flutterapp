import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isTracking = false;

  Future<void> startLocationTracking() async {
    if (_isTracking) return;

    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      _isTracking = true;

      // Start listening to location updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) async {
        if (_auth.currentUser != null) {
          // Update location in Firestore
          await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
            'location': GeoPoint(position.latitude, position.longitude),
            'lastLocationUpdate': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error starting location tracking: $e');
      rethrow;
    }
  }

  Future<void> stopLocationTracking() async {
    _isTracking = false;
  }

  Future<Position> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }
} 