import 'package:flutter/material.dart';
import 'package:homease/models/booking_model.dart';
import 'package:homease/services/booking_service.dart';
import 'package:homease/views/home/service_widgets/request_card.dart';

class AllActiveRequestsScreen extends StatefulWidget {
  const AllActiveRequestsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _AllActiveRequestsScreenState();
}

class _AllActiveRequestsScreenState extends State<AllActiveRequestsScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _activeBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveRequests();
  }

  Future<void> _loadActiveRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _bookingService.getAllActiveRequests();
      _activeBookings = snapshot.docs
          .map((doc) => BookingModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error loading active requests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Requests'),
        backgroundColor: const Color(0xFFF8F1EB),
      ),
      backgroundColor: const Color(0xFFF8F1EB),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _activeBookings.isEmpty
              ? Center(child: Text('No active requests available'))
              : RefreshIndicator(
                  onRefresh: _loadActiveRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activeBookings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: RequestCard(
                          booking: _activeBookings[index],
                          statusLabel: 'Active',
                          onStatusChanged: _loadActiveRequests,
                          showActions: false,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}