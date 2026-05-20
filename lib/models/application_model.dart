// ============================================================
// FILE: auth_viewmodel.dart
// GROUP: W3M
// MEMBERS:
// - Malejane HC 222025549
// - Mokhele KD 221037680
// - Manala E 222057458
// - Mohlohlo K 223010767
// - Modise LS 222021816
// - Nomankonya 216006365
// - Waeza LP 222041368
// DATE: May 2026
// ============================================================// ============================================================
// FILE: application_model.dart
// DESCRIPTION: Application data model
// ============================================================

class ApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;
  final List<Map<String, String>> modules;
  final bool meetsRequirements;
  final String? supportingDocumentUrl;
  final String status; // pending, approved, rejected
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
    List<Map<String, String>> modules = [];

    if (json['modules'] != null && json['modules'] is List) {
      modules = List<Map<String, String>>.from(
        (json['modules'] as List).map((m) => Map<String, String>.from(m)),
      );
    } else if (json['module1_name'] != null &&
        json['module1_name'].toString().isNotEmpty) {
      modules.add({
        'level': json['module1_level']?.toString() ?? 'first-year',
        'name': json['module1_name'].toString(),
      });
      if (json['module2_name'] != null &&
          json['module2_name'].toString().isNotEmpty) {
        modules.add({
          'level': json['module2_level']?.toString() ?? 'first-year',
          'name': json['module2_name'].toString(),
        });
      }
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
      'modules': modules,
      'meets_requirements': meetsRequirements,
      'supporting_document_url': supportingDocumentUrl,
      'status': status,
      'admin_comments': adminComments,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  int get moduleCount => modules.length;
  String get moduleNames => modules.map((m) => m['name']).join(', ');
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasDocument =>
      supportingDocumentUrl != null && supportingDocumentUrl!.isNotEmpty;
}
