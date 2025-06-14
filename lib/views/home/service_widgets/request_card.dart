import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:homease/models/booking_model.dart';
import 'package:homease/services/booking_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestCard extends StatefulWidget {
  final BookingModel booking;
  final String statusLabel;
  final Function() onStatusChanged;
  final bool showActions;

  const RequestCard({
    Key? key,
    required this.booking,
    required this.statusLabel,
    required this.onStatusChanged,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final BookingService _bookingService = BookingService();
  UserModel? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userDoc = await _bookingService.getUserDetails(widget.booking.currentUserId);
      setState(() {
        userDetails = UserModel.fromSnapshot(userDoc);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('h:mm a').format(date);
  }

  String _getTimeRange(Timestamp timestamp) {
    final date = timestamp.toDate();
    final startTime = DateFormat('h:mm a').format(date);
    
    // For demo purposes, adding 2 hours to show a time range
    final endTime = DateFormat('h:mm a').format(
      date.add(const Duration(hours: 2))
    );
    
    return '$startTime - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: Icon(Icons.home_repair_service),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.booking.serviceName, 
                         style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    if (widget.booking.price != null)
                      Text(
                        '\$${widget.booking.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatDate(widget.booking.createdAt)}\n${_getTimeRange(widget.booking.createdAt)}', 
                      style: const TextStyle(fontSize: 10, color: Colors.grey)
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xff48B1DB).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(widget.statusLabel, 
                         style: TextStyle(color: Color(0xff48B1DB))),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(indent: 20, endIndent: 20),
          
          // User details section
          isLoading 
              ? Center(child: CircularProgressIndicator())
              : ListTile(
                  leading: userDetails?.profilePic.isNotEmpty == true
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userDetails!.profilePic,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                  title: Text(userDetails?.name ?? 'Unknown User'),
                ),
                
          // Action buttons
          if (widget.showActions && widget.booking.status == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Row(
                children: [
                  SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _bookingService.updateBookingStatus(
                          widget.booking.id, 
                          'rejected'
                        );
                        widget.onStatusChanged();
                      },
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.black
                        ),
                        child: Center(
                          child: Text(
                            'Decline',
                            style: TextStyle(color: Color(0xff48B1DB)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _bookingService.updateBookingStatus(
                          widget.booking.id, 
                          'accepted'
                        );
                        widget.onStatusChanged();
                      },
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(0xff48B1DB)
                        ),
                        child: Center(
                          child: Text(
                            'Accept',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ),
        ],
      ),
    );
  }
}