import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  String? _serviceName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _address;
  String? _instructions;
  String? _currentUserId;
  String? _serviceProviderId;

  String? get serviceName => _serviceName;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? get address => _address;
  String? get instructions => _instructions;
  String? get currentUserId => _currentUserId;
  String? get serviceProviderId => _serviceProviderId;

  void setBookingData({
    required String serviceName,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String address,
    required String instructions,
    required String currentUserId,
    required String serviceProviderId,
  }) {
    _serviceName = serviceName;
    _selectedDate = selectedDate;
    _selectedTime = selectedTime;
    _address = address;
    _instructions = instructions;
    _currentUserId = currentUserId;
    _serviceProviderId = serviceProviderId;

    notifyListeners();
  }

  void clearBookingData() {
    _serviceName = null;
    _selectedDate = null;
    _selectedTime = null;
    _address = null;
    _instructions = null;
    _currentUserId = null;
    _serviceProviderId = null;

    notifyListeners();
  }

  bool get isBookingDataComplete {
    return _serviceName != null &&
        _selectedDate != null &&
        _selectedTime != null &&
        _address != null &&
        _address!.isNotEmpty &&
        _currentUserId != null &&
        _serviceProviderId != null;
  }
}
