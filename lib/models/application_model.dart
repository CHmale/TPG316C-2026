// lib/models/application_model.dart
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
  final String? supportingDocumentUrl;
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
    this.supportingDocumentUrl,
    required this.status,
    this.adminComments,
    required this.submittedAt,
    this.updatedAt,
  });

  // Factory constructor - converts JSON from Supabase to ApplicationModel
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
      supportingDocumentUrl: json['supporting_document_url'],
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

  // Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'module2_level': module2Level,
      'module2_name': module2Name,
      'meets_requirements': meetsRequirements,
      'supporting_document_url': supportingDocumentUrl,
      'status': status,
      'admin_comments': adminComments,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // COPY WITH - creates a new instance with updated values (immutability)
  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? studentNumber,
    int? yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
    bool? meetsRequirements,
    String? supportingDocumentUrl,
    String? status,
    String? adminComments,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Name: module1Name ?? this.module1Name,
      module2Level: module2Level ?? this.module2Level,
      module2Name: module2Name ?? this.module2Name,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      supportingDocumentUrl:
          supportingDocumentUrl ?? this.supportingDocumentUrl,
      status: status ?? this.status,
      adminComments: adminComments ?? this.adminComments,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // HELPER GETTERS
  // ============================================================

  // Check if second module is present (FIXES YOUR ERROR)
  bool get hasSecondModule => module2Name != null && module2Name!.isNotEmpty;

  // Status checkers
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
