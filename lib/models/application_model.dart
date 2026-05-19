// ============================================================
// FILE: application_model.dart
// MEMBERS:
// - Member 1 (Kamohelo Mohlohlo 223010767)
// - Member 2 (    )
// - Member 3 (    )
// - Member 4 (     )
// - Member 5 (     )
// - Member 6 (     )
// - Member 7 (     )
// DATE: May 2026
// ============================================================
// DESCRIPTION:
// Student Assistant Application data model.
// Stores all application details including multiple modules,
// supporting documents, and approval status.
// ============================================================
// LEARNING OBJECTIVES COVERED:
// - Unit 2: Model layer with JSON serialization
// - Unit 5: Data structure for Supabase CRUD operations
// - Unit 5: JSONB support for multiple modules
// - Unit 5: File storage for supporting documents
// ============================================================

class ApplicationModel {
  // ============================================================
  // MODEL PROPERTIES (Unit 2 - Part 5)
  // Pure Dart class with no Flutter imports
  // All fields final - immutable by design
  // ============================================================
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final int yearOfStudy;
  final List<Map<String, String>> modules;  // Supports 3+ modules (JSONB)
  final bool meetsRequirements;
  final String? supportingDocumentUrl;      // URL of uploaded document in Supabase Storage
  final String status;                      // pending, approved, rejected
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

  // ============================================================
  // FACTORY CONSTRUCTOR (Unit 2 - Part 5)
  // Converts JSON from Supabase to ApplicationModel
  // Handles both new modules format and legacy data
  // ============================================================
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> modules = [];
    
    // Parse modules from JSONB column (new format)
    if (json['modules'] != null && json['modules'] is List) {
      modules = List<Map<String, String>>.from(
        (json['modules'] as List).map((m) => Map<String, String>.from(m))
      );
    } 
    // Handle legacy data from old table structure
    else if (json['module1_name'] != null && json['module1_name'].toString().isNotEmpty) {
      modules.add({
        'level': json['module1_level']?.toString() ?? 'first-year',
        'code': json['module1_name'].toString(),
        'name': _getModuleName(json['module1_name'].toString()),
      });
      if (json['module2_name'] != null && json['module2_name'].toString().isNotEmpty) {
        modules.add({
          'level': json['module2_level']?.toString() ?? 'first-year',
          'code': json['module2_name'].toString(),
          'name': _getModuleName(json['module2_name'].toString()),
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
      supportingDocumentUrl: json['supporting_document_url'],  // Get document URL
      status: json['status'] ?? 'pending',
      adminComments: json['admin_comments'],
      submittedAt: DateTime.parse(json['submitted_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Helper method to get full module names from codes
  static String _getModuleName(String code) {
    const names = {
      'TPG316C': 'Programming Fundamentals',
      'SOD316C': 'Software Development',
      'CMN316C': 'Communication Skills',
      'ITS316C': 'Information Systems',
      'PRG216C': 'Advanced Programming',
      'DBS216C': 'Database Systems',
      'WEB216C': 'Web Development',
      'SYS216C': 'Systems Analysis',
      'PRJ316C': 'Project Management',
      'ADV316C': 'Advanced Databases',
      'Mob316C': 'Mobile Development',
      'NWK316C': 'Networking',
    };
    return names[code] ?? code;
  }

  // ============================================================
  // TO JSON (Unit 5)
  // Converts ApplicationModel to JSON for Supabase operations
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'modules': modules,
      'meets_requirements': meetsRequirements,
      'supporting_document_url': supportingDocumentUrl,  // Include document URL
      'status': status,
      'admin_comments': adminComments,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // COPY WITH (Unit 2 - Part 5)
  // Creates a new instance with updated values (immutability)
  // ============================================================
  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? studentNumber,
    int? yearOfStudy,
    List<Map<String, String>>? modules,
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
      modules: modules ?? this.modules,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      supportingDocumentUrl: supportingDocumentUrl ?? this.supportingDocumentUrl,
      status: status ?? this.status,
      adminComments: adminComments ?? this.adminComments,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // HELPER GETTERS (Unit 2)
  // Computed properties for status checking and display
  // ============================================================
  
  // Module related getters
  int get moduleCount => modules.length;
  String get moduleNames => modules.map((m) => m['name']).join(', ');
  
  // Document related getter - checks if supporting document is attached
  bool get hasDocument => supportingDocumentUrl != null && supportingDocumentUrl!.isNotEmpty;
  
  // Status checkers
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
