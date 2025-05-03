import 'package:flutter/material.dart';
import 'package:homease/models/booking_model.dart';
import 'package:homease/services/booking_service.dart';
import 'package:homease/views/home/service_widgets/request_card.dart';

class AllPendingRequestsScreen extends StatefulWidget {
  final Function() onStatusChanged;
  
  const AllPendingRequestsScreen({
    Key? key,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State createState() => _AllPendingRequestsScreenState();
}

class _AllPendingRequestsScreenState extends State<AllPendingRequestsScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _pendingBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _bookingService.getAllPendingRequests();
      _pendingBookings = snapshot.docs
          .map((doc) => BookingModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error loading pending requests: $e');
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
        title: Text('New Requests'),
        backgroundColor: const Color(0xFFF8F1EB),
      ),
      backgroundColor: const Color(0xFFF8F1EB),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingBookings.isEmpty
              ? Center(child: Text('No pending requests available'))
              : RefreshIndicator(
                  onRefresh: _loadPendingRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingBookings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: RequestCard(
                          booking: _pendingBookings[index],
                          statusLabel: 'New offer',
                          onStatusChanged: () {
                            _loadPendingRequests();
                            widget.onStatusChanged();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}