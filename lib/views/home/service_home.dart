import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/models/booking_model.dart';
import 'package:homease/services/booking_service.dart';
import 'package:homease/views/home/service_widgets/active_req.dart';
import 'package:homease/views/home/service_widgets/header.dart';
import 'package:homease/views/home/service_widgets/pending_req.dart';
import 'package:homease/views/home/service_widgets/request_card.dart';

class ServiceHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ServiceHomeScreen({super.key, required this.scaffoldKey});

  @override
  State<ServiceHomeScreen> createState() => _ServiceHomeScreenState();
}

class _ServiceHomeScreenState extends State<ServiceHomeScreen> {
  final GlobalKey _menuKey = GlobalKey();
  final BookingService _bookingService = BookingService();
  
  bool _isLoading = true;
  BookingModel? _latestPendingBooking;
  BookingModel? _latestActiveBooking;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch newest pending request
      final pendingSnapshot = await _bookingService.getNewestPendingRequest();
      if (pendingSnapshot.docs.isNotEmpty) {
        _latestPendingBooking = BookingModel.fromSnapshot(pendingSnapshot.docs.first);
      } else {
        _latestPendingBooking = null;
      }
      
      // Fetch newest active request
      final activeSnapshot = await _bookingService.getNewestActiveRequest();
      if (activeSnapshot.docs.isNotEmpty) {
        _latestActiveBooking = BookingModel.fromSnapshot(activeSnapshot.docs.first);
      } else {
        _latestActiveBooking = null;
      }
    } catch (e) {
      print('Error loading bookings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPopupMenu() {
    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + button.size.height + 5,
      offset.dx + button.size.width,
      0,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      items: [
        _popupItem('Phone Consultation'),
        _popupItem('New on Platform'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F1EB),
        actions: [
          _iconButton('assets/icons/bell.svg', () {
            // Notification logic
          }),
          _iconButton('assets/icons/vert_bars.svg', () {
            widget.scaffoldKey.currentState?.openDrawer();
          }),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              key: _menuKey,
              onTap: _showPopupMenu,
              child: _iconContainer(child: const Icon(Icons.more_vert)),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F1EB),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadBookings,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Header(),
                        const SizedBox(height: 20),

                        // My Services
                        // MyServices(),
                        // const SizedBox(height: 20),

                        // New Requests
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('New requests', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllPendingRequestsScreen(
                                      onStatusChanged: _loadBookings,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View all', 
                                  style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        _latestPendingBooking != null
                            ? RequestCard(
                                booking: _latestPendingBooking!,
                                statusLabel: 'New offer',
                                onStatusChanged: _loadBookings,
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text('No new requests available'),
                                ),
                              ),

                        const SizedBox(height: 20),

                        // Active Requests
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Active requests', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllActiveRequestsScreen(),
                                  ),
                                );
                              },
                              child: const Text('View all', 
                                  style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        _latestActiveBooking != null
                            ? RequestCard(
                                booking: _latestActiveBooking!,
                                statusLabel: 'Active',
                                onStatusChanged: _loadBookings,
                                showActions: false,
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text('No active requests available'),
                                ),
                              ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _iconButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: _iconContainer(
          child: SvgPicture.asset(assetPath, width: 20, height: 20),
        ),
      ),
    );
  }

  Widget _iconContainer({required Widget child}) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: child),
    );
  }
}

PopupMenuItem _popupItem(String title) {
  return PopupMenuItem(
    value: title,
    child: Text(title),
  );
}