// models/application_model.dart
class ApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;
  final String module1Level;
  final String module1Name;
  final String? module2Level;
  final String? module2Name;
  final bool meetsRequirements;
  final String status;
  final String? adminComments;
  final DateTime submittedAt;
  final DateTime? updatedAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.meetsRequirements,
    required this.status,
    this.adminComments,
    required this.submittedAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      module1Level: json['module1_level'] ?? '',
      module1Name: json['module1_name'] ?? '',
      module2Level: json['module2_level'],
      module2Name: json['module2_name'],
      meetsRequirements: json['meets_requirements'] ?? false,
      status: json['status'] ?? 'pending',
      adminComments: json['admin_comments'],
      submittedAt: DateTime.parse(
        json['submitted_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
