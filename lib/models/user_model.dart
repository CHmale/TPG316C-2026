// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

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

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
}
