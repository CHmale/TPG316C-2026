// ============================================================
// FILE: application_viewmodel.dart
// MEMBERS:
// - Malejane HC 222025549
// - Mokhele KD 221037680
// - Manala E 222057458
// - Mohlohlo K 223010767
// - Modise LS 222021816
// - Nomankonya 216006365
// - Waeza LP 222041368
// DATE: May 2026
// ============================================================
// DESCRIPTION:
// Application ViewModel - manages CRUD operations for
// Student Assistant applications.
// ============================================================
// LEARNING OBJECTIVES COVERED:
// - Unit 2: ViewModel with ChangeNotifier
// - Unit 5: CRUD operations (Create, Read, Update, Delete)
// - Unit 5: Supabase database integration
// - Unit 5: Row Level Security (RLS) compliance
// ============================================================
// ============================================================
// FILE: application_viewmodel.dart
// COMPLETE WORKING VERSION - FIXED PGRST204
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      _applications =
          response.map((json) => ApplicationModel.fromJson(json)).toList();
      print('Fetched ${_applications.length} applications');
    } catch (e) {
      _errorMessage = e.toString();
      print('Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ApplicationModel? getApplicationById(String id) {
    try {
      return _applications.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // FIXED: addApplication - Proper JSON format for modules
  // ============================================================
  Future<bool> addApplication({
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
    String? documentUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;

      // Check existing application
      final existing = await _supabase
          .from('applications')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      if (existing != null) {
        _errorMessage = 'You have already submitted an application.';
        return false;
      }

      //CRITICAL: Convert modules to List<Map<String, dynamic>> with string values
      final List<Map<String, dynamic>> modulesJson = modules.map((m) {
        return {
          'level': m['level'] ?? 'first-year',
          'name': m['name'] ?? '',
        };
      }).toList();

      final data = {
        'user_id': userId,
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'modules': modulesJson, // Must be a list of maps
        'meets_requirements': meetsRequirements,
        'supporting_document_url': documentUrl,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      print('Sending data: ${data.toString()}');

      final response = await _supabase
          .from('applications')
          .insert(data)
          .select(); // .select() is fine when data is correct

      if (response.isNotEmpty) {
        await fetchApplications();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('Add error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FIXED: updateApplication
  // ============================================================
  Future<bool> updateApplication({
    required String id,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
    String? documentUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final oldApplication = getApplicationById(id);
      if (oldApplication == null || !oldApplication.isPending) {
        _errorMessage = 'Only pending applications can be edited.';
        return false;
      }

      // Format modules as JSON array of objects
      final List<Map<String, dynamic>> formattedModules = modules.map((module) {
        return {
          'level': module['level'] ?? 'first-year',
          'name': module['name'] ?? '',
        };
      }).toList();

      final updatedData = {
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'modules': formattedModules,
        'meets_requirements': meetsRequirements,
        'supporting_document_url': documentUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Updating application $id with: $updatedData');

      await _supabase
          .from('applications')
          .update(updatedData)
          .match({'id': id});

      await fetchApplications();
      print('Application updated successfully!');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteApplication(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final application = getApplicationById(id);
      if (application == null || !application.isPending) {
        _errorMessage = 'Only pending applications can be deleted.';
        return false;
      }

      await _supabase.from('applications').delete().match({'id': id});
      _applications.removeWhere((app) => app.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
