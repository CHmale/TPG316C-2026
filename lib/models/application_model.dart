// lib/models/application_model.dart
class ApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;

  // Changed from single module to list of modules
  final List<Map<String, String>>
  modules; // [{level: 'first-year', name: 'TPG316C'}, ...]

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
    required this.modules,
    required this.meetsRequirements,
    this.supportingDocumentUrl,
    required this.status,
    this.adminComments,
    required this.submittedAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Parse modules from JSON (stored as JSONB in Supabase)
    List<Map<String, String>> modules = [];
    if (json['modules'] != null) {
      modules = List<Map<String, String>>.from(
        json['modules'].map((m) => Map<String, String>.from(m)),
      );
    }

    return ApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      modules: modules,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'modules': modules, // Store as JSONB
      'meets_requirements': meetsRequirements,
      'supporting_document_url': supportingDocumentUrl,
      'status': status,
      'admin_comments': adminComments,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get hasSecondModule => modules.length >= 2;
  bool get hasThirdModule => modules.length >= 3;
  int get moduleCount => modules.length;
  String get moduleNames => modules.map((m) => m['name']).join(', ');

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
