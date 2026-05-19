// lib/viewmodels/application_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

// Custom color scheme for application states
class ApplicationColors {
  static const Color primary = Color(0xFF6C63FF);     // Modern Purple
  static const Color secondary = Color(0xFFFF6584);   // Coral Pink
  static const Color accent = Color(0xFF00D2FF);      // Cyan
  static const Color pending = Color(0xFFFFA726);     // Warm Orange
  static const Color approved = Color(0xFF4CAF50);    // Fresh Green
  static const Color rejected = Color(0xFFEF5350);    // Soft Red
  static const Color success = Color(0xFF00B894);     // Mint Green
  static const Color error = Color(0xFFD63031);       // Deep Red
  static const Color warning = Color(0xFFFDCB6E);     // Golden Yellow
  static const Color info = Color(0xFF0984E3);        // Bright Blue
  static const Color background = Color(0xFFF8F9FA);  // Light Gray
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray
}

enum ApplicationStatus { pending, approved, rejected, all }

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.all:
        return 'All';
    }
  }
  
  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return ApplicationColors.pending;
      case ApplicationStatus.approved:
        return ApplicationColors.approved;
      case ApplicationStatus.rejected:
        return ApplicationColors.rejected;
      case ApplicationStatus.all:
        return ApplicationColors.primary;
    }
  }
  
  IconData get icon {
    switch (this) {
      case ApplicationStatus.pending:
        return Icons.pending_actions;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.all:
        return Icons.list_alt;
    }
  }
}

class ApplicationState {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? operationInProgress;
  final ApplicationStatus filterStatus;
  final String? searchQuery;
  final Map<String, bool> expandedCards;
  final Set<String> selectedApplications;

  const ApplicationState({
    this.applications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.operationInProgress,
    this.filterStatus = ApplicationStatus.all,
    this.searchQuery,
    this.expandedCards = const {},
    this.selectedApplications = const {},
  });

  ApplicationState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? operationInProgress,
    ApplicationStatus? filterStatus,
    String? searchQuery,
    Map<String, bool>? expandedCards,
    Set<String>? selectedApplications,
  }) {
    return ApplicationState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      operationInProgress: operationInProgress ?? this.operationInProgress,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedCards: expandedCards ?? this.expandedCards,
      selectedApplications: selectedApplications ?? this.selectedApplications,
    );
  }

  List<ApplicationModel> get filteredApplications {
    var result = applications;

    // Apply status filter
    if (filterStatus != ApplicationStatus.all) {
      result = result.where((app) {
        switch (filterStatus) {
          case ApplicationStatus.pending:
            return app.isPending;
          case ApplicationStatus.approved:
            return app.status == 'approved';
          case ApplicationStatus.rejected:
            return app.status == 'rejected';
          case ApplicationStatus.all:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      result = result.where((app) {
        return app.fullName.toLowerCase().contains(searchQuery!.toLowerCase()) ||
            app.studentNumber.contains(searchQuery!);
      }).toList();
    }

    return result;
  }

  List<ApplicationModel> get pendingApplications => 
      applications.where((a) => a.isPending).toList();
  
  List<ApplicationModel> get approvedApplications => 
      applications.where((a) => a.status == 'approved').toList();
  
  List<ApplicationModel> get rejectedApplications => 
      applications.where((a) => a.status == 'rejected').toList();

  Map<String, int> get statusCounts {
    return {
      'pending': pendingApplications.length,
      'approved': approvedApplications.length,
      'rejected': rejectedApplications.length,
      'total': applications.length,
    };
  }
  
  double get approvalRate {
    if (applications.isEmpty) return 0;
    return approvedApplications.length / applications.length;
  }
  
  bool get hasSelection => selectedApplications.isNotEmpty;
  int get selectedCount => selectedApplications.length;
}

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  ApplicationState _state = const ApplicationState();

  ApplicationState get state => _state;
  List<ApplicationModel> get applications => _state.applications;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;
  String? get operationInProgress => _state.operationInProgress;
  List<ApplicationModel> get filteredApplications => _state.filteredApplications;
  Map<String, int> get statusCounts => _state.statusCounts;
  double get approvalRate => _state.approvalRate;
  bool get hasSelection => _state.hasSelection;
  int get selectedCount => _state.selectedCount;
  
  // Admin specific
  List<ApplicationModel> get allApplications => _state.applications;
  
  // UI Helpers
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationColors.pending;
      case 'approved':
        return ApplicationColors.approved;
      case 'rejected':
        return ApplicationColors.rejected;
      default:
        return ApplicationColors.info;
    }
  }
  
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
  
  Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withOpacity(0.1);
  }
  
  Color getCardColor(ApplicationModel application) {
    if (application.isPending) {
      return ApplicationColors.pending.withOpacity(0.05);
    } else if (application.status == 'approved') {
      return ApplicationColors.approved.withOpacity(0.05);
    } else if (application.status == 'rejected') {
      return ApplicationColors.rejected.withOpacity(0.05);
    }
    return ApplicationColors.background;
  }
  
  void toggleCardExpansion(String applicationId) {
    final newExpanded = Map<String, bool>.from(_state.expandedCards);
    newExpanded[applicationId] = !(newExpanded[applicationId] ?? false);
    _state = _state.copyWith(expandedCards: newExpanded);
    notifyListeners();
  }
  
  bool isCardExpanded(String applicationId) {
    return _state.expandedCards[applicationId] ?? false;
  }
  
  void toggleSelection(String applicationId) {
    final newSelection = Set<String>.from(_state.selectedApplications);
    if (newSelection.contains(applicationId)) {
      newSelection.remove(applicationId);
    } else {
      newSelection.add(applicationId);
    }
    _state = _state.copyWith(selectedApplications: newSelection);
    notifyListeners();
  }
  
  bool isSelected(String applicationId) {
    return _state.selectedApplications.contains(applicationId);
  }
  
  void clearSelection() {
    _state = _state.copyWith(selectedApplications: {});
    notifyListeners();
  }
  
  void setFilter(ApplicationStatus status) {
    _state = _state.copyWith(filterStatus: status);
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }
  
  void clearFilters() {
    _state = _state.copyWith(
      filterStatus: ApplicationStatus.all,
      searchQuery: null,
    );
    notifyListeners();
  }
  
  void clearMessages() {
    _state = _state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
    notifyListeners();
  }

  Future<void> fetchApplications({bool forAdmin = false}) async {
    _setLoading(true);
    _clearMessages();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null && !forAdmin) return;

      var query = _supabase.from('applications').select();
      
      if (!forAdmin) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('submitted_at', ascending: false);

      final applications = response
          .map((json) => ApplicationModel.fromJson(json))
          .toList();

      _state = _state.copyWith(
        applications: applications, 
        errorMessage: null,
        successMessage: applications.isEmpty 
            ? 'No applications found. Submit your first application!'
            : 'Loaded ${applications.length} application(s)',
      );
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to load applications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<ApplicationModel?> getApplicationById(String id) async {
    try {
      // Try to find in cache first
      var app = _state.applications.firstWhere(
        (app) => app.id == id,
        orElse: () => throw Exception(),
      );
      return app;
    } catch (e) {
      // Fetch from server if not in cache
      try {
        final response = await _supabase
            .from('applications')
            .select()
            .eq('id', id)
            .maybeSingle();
        
        if (response != null) {
          return ApplicationModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Error fetching application: $e');
      }
      return null;
    }
  }

  Future<ApplicationResult> addApplication({
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
  }) async {
    _setOperation('Submitting application...');
    _clearMessages();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return ApplicationResult.error('User not logged in');
      }

      // Check for existing application
      final existingCheck = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existingCheck != null) {
        return ApplicationResult.error('You have already submitted an application');
      }

      // Validate modules
      final validationError = _validateModulesWithMessage(modules);
      if (validationError != null) {
        return ApplicationResult.error(validationError);
      }

      final applicationData = {
        'user_id': userId,
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'modules': modules,
        'meets_requirements': meetsRequirements,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('applications')
          .insert(applicationData)
          .select();

      if (response.isNotEmpty) {
        final newApplication = ApplicationModel.fromJson(response.first);
        _state = _state.copyWith(
          applications: [newApplication, ..._state.applications],
          successMessage: 'Application submitted successfully!',
        );
        notifyListeners();
        return ApplicationResult.success(newApplication);
      }
      
      return ApplicationResult.error('Failed to submit application');
    } catch (e) {
      return ApplicationResult.error('Submission failed: ${e.toString()}');
    } finally {
      _clearOperation();
    }
  }

  Future<ApplicationResult> updateApplication({
    required String id,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
  }) async {
    _setOperation('Updating application...');
    _clearMessages();

    try {
      final application = await getApplicationById(id);
      
      if (application == null) {
        return ApplicationResult.error('Application not found');
      }
      
      if (!application.isPending) {
        return ApplicationResult.error('Only pending applications can be edited');
      }

      final validationError = _validateModulesWithMessage(modules);
      if (validationError != null) {
        return ApplicationResult.error(validationError);
      }

      final updatedData = {
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'modules': modules,
        'meets_requirements': meetsRequirements,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('applications').update(updatedData).eq('id', id);

      // Update local cache
      final updatedApplications = _state.applications.map((app) {
        if (app.id == id) {
          return app.copyWith(
            fullName: fullName,
            studentNumber: studentNumber,
            yearOfStudy: yearOfStudy,
            modules: modules.map((m) => Module.fromJson(m)).toList(),
            meetsRequirements: meetsRequirements,
          );
        }
        return app;
      }).toList();

      _state = _state.copyWith(
        applications: updatedApplications,
        successMessage: 'Application updated successfully!',
      );
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error('Update failed: ${e.toString()}');
    } finally {
      _clearOperation();
    }
  }

  Future<ApplicationResult> deleteApplication(String id) async {
    _setOperation('Deleting application...');
    _clearMessages();

    try {
      final application = await getApplicationById(id);
      
      if (application == null) {
        return ApplicationResult.error('Application not found');
      }
      
      if (!application.isPending) {
        return ApplicationResult.error('Only pending applications can be deleted');
      }

      await _supabase.from('applications').delete().eq('id', id);

      final updatedApplications = _state.applications
          .where((app) => app.id != id)
          .toList();
      
      final newExpanded = Map<String, bool>.from(_state.expandedCards);
      newExpanded.remove(id);
      
      final newSelection = Set<String>.from(_state.selectedApplications);
      newSelection.remove(id);

      _state = _state.copyWith(
        applications: updatedApplications,
        expandedCards: newExpanded,
        selectedApplications: newSelection,
        successMessage: 'Application deleted successfully!',
      );
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error('Deletion failed: ${e.toString()}');
    } finally {
      _clearOperation();
    }
  }

  // Admin methods
  Future<ApplicationResult> updateApplicationStatus({
    required String id,
    required String status,
    String? adminNotes,
  }) async {
    _setOperation(status == 'approved' ? 'Approving application...' : 'Rejecting application...');
    _clearMessages();

    try {
      final validStatuses = ['approved', 'rejected'];
      if (!validStatuses.contains(status)) {
        return ApplicationResult.error('Invalid status');
      }

      final updates = {
        'status': status,
        'reviewed_at': DateTime.now().toIso8601String(),
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

      await _supabase.from('applications').update(updates).eq('id', id);

      // Update local cache
      final updatedApplications = _state.applications.map((app) {
        if (app.id == id) {
          return app.copyWith(status: status);
        }
        return app;
      }).toList();

      _state = _state.copyWith(
        applications: updatedApplications,
        successMessage: 'Application ${status == 'approved' ? 'approved' : 'rejected'} successfully!',
      );
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error('Status update failed: ${e.toString()}');
    } finally {
      _clearOperation();
    }
  }
  
  // Bulk operations for admin
  Future<ApplicationResult> bulkUpdateStatus({
    required Set<String> applicationIds,
    required String status,
    String? adminNotes,
  }) async {
    if (applicationIds.isEmpty) {
      return ApplicationResult.error('No applications selected');
    }
    
    _setOperation('Updating ${applicationIds.length} application(s)...');
    _clearMessages();
    
    int successCount = 0;
    int failCount = 0;
    
    for (final id in applicationIds) {
      final result = await updateApplicationStatus(
        id: id,
        status: status,
        adminNotes: adminNotes,
      );
      if (result.success) {
        successCount++;
      } else {
        failCount++;
      }
    }
    
    _clearOperation();
    
    if (failCount == 0) {
      _state = _state.copyWith(
        successMessage: 'Successfully ${status == 'approved' ? 'approved' : 'rejected'} $successCount application(s)',
        selectedApplications: {},
      );
      notifyListeners();
      return ApplicationResult.success();
    } else {
      return ApplicationResult.error('Updated $successCount, failed: $failCount');
    }
  }

  Future<List<ApplicationModel>> searchApplications(String query) async {
    if (query.isEmpty) return _state.applications;

    return _state.applications.where((app) {
      return app.fullName.toLowerCase().contains(query.toLowerCase()) ||
          app.studentNumber.contains(query) ||
          app.id.contains(query);
    }).toList();
  }
  
  String? _validateModulesWithMessage(List<Map<String, String>> modules) {
    if (modules.isEmpty) return 'Please select at least one module';
    if (modules.length < 3) return 'Minimum 3 modules required';
    if (modules.length > 8) return 'Maximum 8 modules allowed';
    
    // Check for duplicate module codes
    final moduleCodes = modules.map((m) => m['code']).toSet();
    if (moduleCodes.length != modules.length) {
      return 'Duplicate modules are not allowed';
    }
    
    return null;
  }
  
  bool _validateModules(List<Map<String, String>> modules) {
    return _validateModulesWithMessage(modules) == null;
  }

  void _setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }
  
  void _setOperation(String operation) {
    _state = _state.copyWith(operationInProgress: operation);
    notifyListeners();
  }
  
  void _clearOperation() {
    _state = _state.copyWith(operationInProgress: null);
    notifyListeners();
  }
  
  void _clearMessages() {
    _state = _state.copyWith(errorMessage: null, successMessage: null);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}

class ApplicationResult {
  final bool success;
  final String? error;
  final ApplicationModel? application;

  ApplicationResult._({required this.success, this.error, this.application});

  factory ApplicationResult.success([ApplicationModel? application]) {
    return ApplicationResult._(success: true, application: application);
  }

  factory ApplicationResult.error(String message) {
    return ApplicationResult._(success: false, error: message);
  }
}
