import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class AdminState {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.applications = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminState _state = const AdminState();
  AdminState get state => _state;

  List<ApplicationModel> get applications => _state.applications;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  // =========================
  // STATS
  // =========================
  int get total => applications.length;
  int get pending =>
      applications.where((a) => a.isPending).length;
  int get approved =>
      applications.where((a) => a.isApproved).length;
  int get rejected =>
      applications.where((a) => a.isRejected).length;

  // =========================
  // FETCH
  // =========================
  Future<void> fetchApplications() async {
    _updateState(isLoading: true, error: null);

    try {
      final data = await _supabase
          .from('applications')
          .select()
          .order('submitted_at', ascending: false);

      final list = (data as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();

      _updateState(applications: list);
    } catch (e) {
      _updateState(error: e.toString());
    } finally {
      _updateState(isLoading: false);
    }
  }

  // =========================
  // APPROVE / REJECT SHARED
  // =========================
  Future<bool> _updateStatus({
    required String id,
    required String status,
    required String comment,
  }) async {
    _updateState(isLoading: true, error: null);

    try {
      await _supabase.from('applications').update({
        'status': status,
        'admin_comments': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      await fetchApplications();
      return true;
    } catch (e) {
      _updateState(error: e.toString());
      return false;
    } finally {
      _updateState(isLoading: false);
    }
  }

  Future<bool> approve(String id, {String? comment}) {
    return _updateStatus(
      id: id,
      status: 'approved',
      comment: comment ?? 'Approved',
    );
  }

  Future<bool> reject(String id, {required String reason}) {
    return _updateStatus(
      id: id,
      status: 'rejected',
      comment: reason,
    );
  }

  // =========================
  // DELETE
  // =========================
  Future<bool> delete(String id) async {
    _updateState(isLoading: true, error: null);

    try {
      await _supabase
          .from('applications')
          .delete()
          .eq('id', id);

      final updated = applications
          .where((a) => a.id != id)
          .toList();

      _updateState(applications: updated);
      return true;
    } catch (e) {
      _updateState(error: e.toString());
      return false;
    } finally {
      _updateState(isLoading: false);
    }
  }

  // =========================
  // STATE UPDATER
  // =========================
  void _updateState({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? error,
  }) {
    _state = _state.copyWith(
      applications: applications,
      isLoading: isLoading,
      error: error,
    );
    notifyListeners();
  }

  void clearError() {
    _updateState(error: null);
  }
}
