// lib/viewmodels/admin_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ApplicationModel> _allApplications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get allApplications => _allApplications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalApplications => _allApplications.length;
  int get pendingCount => _allApplications.where((app) => app.isPending).length;
  int get approvedCount =>
      _allApplications.where((app) => app.isApproved).length;
  int get rejectedCount =>
      _allApplications.where((app) => app.isRejected).length;

  Future<void> fetchAllApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('applications')
          .select()
          .order('submitted_at', ascending: false);

      _allApplications = response
          .map((json) => ApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? comments,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from('applications')
          .update({
            'status': newStatus,
            'admin_comments': comments,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .match({'id': applicationId});

      await fetchAllApplications();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveApplication(
    String applicationId, {
    String? comments,
  }) async {
    return updateApplicationStatus(
      applicationId: applicationId,
      newStatus: 'approved',
      comments: comments ?? 'Application approved.',
    );
  }

  Future<bool> rejectApplication(
    String applicationId, {
    required String reason,
  }) async {
    return updateApplicationStatus(
      applicationId: applicationId,
      newStatus: 'rejected',
      comments: reason,
    );
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('applications').delete().match({
        'id': applicationId,
      });
      _allApplications.removeWhere((app) => app.id == applicationId);
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
