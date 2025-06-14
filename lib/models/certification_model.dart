class CertificationModel {
  final String id;
  final String title;
  final String issuer;
  final String description;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? certificateUrl;
  final bool isQualification;

  CertificationModel({
    required this.id,
    required this.title,
    required this.issuer,
    required this.description,
    required this.issueDate,
    this.expiryDate,
    this.certificateUrl,
    this.isQualification = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'description': description,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'certificateUrl': certificateUrl,
      'isQualification': isQualification,
    };
  }

  factory CertificationModel.fromMap(Map<String, dynamic> map) {
    return CertificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      issuer: map['issuer'] ?? '',
      description: map['description'] ?? '',
      issueDate: DateTime.parse(map['issueDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      certificateUrl: map['certificateUrl'],
      isQualification: map['isQualification'] ?? false,
    );
  }
} 