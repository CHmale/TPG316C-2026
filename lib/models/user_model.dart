

// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.createdAt,
  });

  /// Factory constructor with safer parsing
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'student').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      studentNumber: (json['student_number'] ?? '').toString(),
      yearOfStudy: _parseInt(json['year_of_study'], defaultValue: 1),
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Convert object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'full_name': fullName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper: safe int parsing
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  /// Helper: safe date parsing
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  /// Role helpers
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStudent => role.toLowerCase() == 'student';

  /// Optional: copyWith (useful for updates)
  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? fullName,
    String? studentNumber,
    int? yearOfStudy,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
