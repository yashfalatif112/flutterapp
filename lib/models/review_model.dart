class ReviewModel {
  final String id;
  final String serviceProviderId;
  final String customerId;
  final String customerName;
  final String customerImage;
  final double rating;
  final String review;
  final DateTime timestamp;
  final String bookingId;

  ReviewModel({
    required this.id,
    required this.serviceProviderId,
    required this.customerId,
    required this.customerName,
    required this.customerImage,
    required this.rating,
    required this.review,
    required this.timestamp,
    required this.bookingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceProviderId': serviceProviderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'rating': rating,
      'review': review,
      'timestamp': timestamp.toIso8601String(),
      'bookingId': bookingId,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      serviceProviderId: map['serviceProviderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerImage: map['customerImage'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      review: map['review'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      bookingId: map['bookingId'] ?? '',
    );
  }
} 