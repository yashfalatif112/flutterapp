import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TrackBookingScreen extends StatefulWidget {
  final String bookingId;
  final String serviceProviderId;

  const TrackBookingScreen({
    super.key,
    required this.bookingId,
    required this.serviceProviderId,
  });

  @override
  State<TrackBookingScreen> createState() => _TrackBookingScreenState();
}

class _TrackBookingScreenState extends State<TrackBookingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _serviceProviderLocation;
  bool _isLoading = true;
  String _serviceProviderName = '';
  String _serviceProviderImage = '';
  String _estimatedArrival = '';

  @override
  void initState() {
    super.initState();
    _loadServiceProviderData();
    _startLocationTracking();
  }

  Future<void> _loadServiceProviderData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.serviceProviderId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _serviceProviderName = userDoc.data()?['name'] ?? 'Unknown';
          _serviceProviderImage = userDoc.data()?['profilePic'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading service provider data: $e');
    }
  }

  void _startLocationTracking() {
    // Listen to service provider's location updates
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.serviceProviderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['location'] != null) {
          final location = data['location'] as GeoPoint;
          final newLocation = LatLng(location.latitude, location.longitude);
          
          setState(() {
            _serviceProviderLocation = newLocation;
            _markers = {
              Marker(
                markerId: const MarkerId('serviceProvider'),
                position: newLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            };
          });

          // Calculate estimated arrival time
          _calculateEstimatedArrival(newLocation);
        }
      }
    });
  }

  Future<void> _calculateEstimatedArrival(LatLng providerLocation) async {
    try {
      // Get booking address from Firestore
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingDoc.exists) {
        final address = bookingDoc.data()?['address'] as String?;
        if (address != null) {
          // Convert address to coordinates
          final locations = await locationFromAddress(address);
          if (locations.isNotEmpty) {
            final destination = locations.first;
            
            // Calculate distance and estimated time
            final distance = Geolocator.distanceBetween(
              providerLocation.latitude,
              providerLocation.longitude,
              destination.latitude,
              destination.longitude,
            );

            // Assuming average speed of 30 km/h
            final estimatedMinutes = (distance / 500).round();
            setState(() {
              _estimatedArrival = '$estimatedMinutes minutes';
            });
          }
        }
      }
    } catch (e) {
      print('Error calculating estimated arrival: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8ed),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Service Provider',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _serviceProviderLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _serviceProviderLocation!,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: _serviceProviderImage.isNotEmpty
                          ? NetworkImage(_serviceProviderImage)
                          : null,
                      child: _serviceProviderImage.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _serviceProviderName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimated arrival: $_estimatedArrival',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 