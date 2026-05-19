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

  // =========================
  // LOADING HELPER
  // =========================
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // FETCH
  // =========================
  Future<void> fetchApplications() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        _applications = [];
        _errorMessage = "User not logged in";
        return;
      }

      final response = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      final data = response as List<dynamic>;

      _applications =
          data.map((e) => ApplicationModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET BY ID
  // =========================
  ApplicationModel? getApplicationById(String id) {
    try {
      return _applications.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // ADD
  // =========================
  Future<bool> addApplication({
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        _errorMessage = "User not logged in";
        return false;
      }

      final existingCheck = await _supabase
          .from('applications')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingCheck != null) {
        _errorMessage = "You have already submitted an application.";
        return false;
      }

      final response = await _supabase
          .from('applications')
          .insert({
            'user_id': userId,
            'full_name': fullName,
            'student_number': studentNumber,
            'year_of_study': yearOfStudy,
            'modules': modules,
            'meets_requirements': meetsRequirements,
            'status': 'pending',
            'submitted_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final newApp = ApplicationModel.fromJson(response);

      _applications.insert(0, newApp);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<bool> updateApplication({
    required String id,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required List<Map<String, String>> modules,
    required bool meetsRequirements,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final index = _applications.indexWhere((e) => e.id == id);

      if (index == -1 || !_applications[index].isPending) {
        _errorMessage = "Only pending applications can be edited.";
        return false;
      }

      final updated = await _supabase
          .from('applications')
          .update({
            'full_name': fullName,
            'student_number': studentNumber,
            'year_of_study': yearOfStudy,
            'modules': modules,
            'meets_requirements': meetsRequirements,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      _applications[index] = ApplicationModel.fromJson(updated);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<bool> deleteApplication(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final app = getApplicationById(id);

      if (app == null || !app.isPending) {
        _errorMessage = "Only pending applications can be deleted.";
        return false;
      }

      await _supabase.from('applications').delete().eq('id', id);

      _applications.removeWhere((e) => e.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
