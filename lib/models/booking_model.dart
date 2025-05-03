import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String serviceName;
  final Timestamp createdAt;
  final String status;
  final String currentUserId;

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.createdAt,
    required this.status,
    required this.currentUserId,
  });

  factory BookingModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BookingModel(
      id: snapshot.id,
      serviceName: data['serviceName'] ?? 'Unknown Service',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      currentUserId: data['currentUserId'] ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String address;
  final String profilePic;

  UserModel({
    required this.id,
    required this.name,
    required this.address,
    required this.profilePic,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      id: snapshot.id,
      name: data['name'] ?? 'Unknown User',
      address: data['address'] ?? 'Unknown Location',
      profilePic: data['profilePic'] ?? '',
    );
  }
}