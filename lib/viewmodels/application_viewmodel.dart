// lib/viewmodels/application_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

enum ApplicationStatus { pending, approved, rejected, all }

class ApplicationState {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final String? errorMessage;
  final ApplicationStatus filterStatus;
  final String? searchQuery;

  const ApplicationState({
    this.applications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStatus = ApplicationStatus.all,
    this.searchQuery,
  });

  ApplicationState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? errorMessage,
    ApplicationStatus? filterStatus,
    String? searchQuery,
  }) {
    return ApplicationState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
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

  Map<String, int> get statusCounts {
    return {
      'pending': applications.where((a) => a.isPending).length,
      'approved': applications.where((a) => a.status == 'approved').length,
      'rejected': applications.where((a) => a.status == 'rejected').length,
      'total': applications.length,
    };
  }
}

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  ApplicationState _state = const ApplicationState();

  ApplicationState get state => _state;
  List<ApplicationModel> get applications => _state.applications;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  List<ApplicationModel> get filteredApplications => _state.filteredApplications;
  
  // Admin specific
  List<ApplicationModel> get allApplications => _state.applications;
  
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

  Future<void> fetchApplications({bool forAdmin = false}) async {
    _setLoading(true);

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

      _state = _state.copyWith(applications: applications, errorMessage: null);
    } catch (e) {
      _state = _state.copyWith(errorMessage: e.toString());
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
    _setLoading(true);

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
      if (!_validateModules(modules)) {
        return ApplicationResult.error('Invalid module selection');
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
        );
        notifyListeners();
        return ApplicationResult.success(newApplication);
      }
      
      return ApplicationResult.error('Failed to submit application');
    } catch (e) {
      return ApplicationResult.error(e.toString());
    } finally {
      _setLoading(false);
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
    _setLoading(true);

    try {
      final application = await getApplicationById(id);
      
      if (application == null) {
        return ApplicationResult.error('Application not found');
      }
      
      if (!application.isPending) {
        return ApplicationResult.error('Only pending applications can be edited');
      }

      if (!_validateModules(modules)) {
        return ApplicationResult.error('Invalid module selection');
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

      _state = _state.copyWith(applications: updatedApplications);
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<ApplicationResult> deleteApplication(String id) async {
    _setLoading(true);

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

      _state = _state.copyWith(applications: updatedApplications);
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Admin methods
  Future<ApplicationResult> updateApplicationStatus({
    required String id,
    required String status,
    String? adminNotes,
  }) async {
    _setLoading(true);

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

      _state = _state.copyWith(applications: updatedApplications);
      notifyListeners();
      
      return ApplicationResult.success();
    } catch (e) {
      return ApplicationResult.error(e.toString());
    } finally {
      _setLoading(false);
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

  bool _validateModules(List<Map<String, String>> modules) {
    if (modules.length < 3) return false;
    if (modules.length > 8) return false;
    
    // Check for duplicate module codes
    final moduleCodes = modules.map((m) => m['code']).toSet();
    return moduleCodes.length == modules.length;
  }

  void _setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
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
