class PortfolioModel {
  final int totalProjects;
  final double totalSpent;
  final List<String> skills;
  final String bio;
  final List<String> achievements;

  PortfolioModel({
    required this.totalProjects,
    required this.totalSpent,
    required this.skills,
    required this.bio,
    required this.achievements,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalProjects': totalProjects,
      'totalSpent': totalSpent,
      'skills': skills,
      'bio': bio,
      'achievements': achievements,
    };
  }

  factory PortfolioModel.fromMap(Map<String, dynamic> map) {
    return PortfolioModel(
      totalProjects: map['totalProjects'] ?? 0,
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      skills: List<String>.from(map['skills'] ?? []),
      bio: map['bio'] ?? '',
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }
} 