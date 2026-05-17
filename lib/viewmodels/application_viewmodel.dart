// viewmodels/application_viewmodel.dart
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

  // Fetch applications for current user
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

      _applications = response
          .map((json) => ApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit new application
  Future<bool> addApplication({
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool meetsRequirements,
    required bool hasSecondModule,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase.from('applications').insert({
        'user_id': userId,
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'module1_level': module1Level,
        'module1_name': module1Name,
        'module2_level': hasSecondModule ? module2Level : null,
        'module2_name': hasSecondModule ? module2Name : null,
        'meets_requirements': meetsRequirements,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isNotEmpty) {
        await fetchApplications(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete application
  Future<bool> deleteApplication(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
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
