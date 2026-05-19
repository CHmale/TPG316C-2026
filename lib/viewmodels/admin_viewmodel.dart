import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  bool get isAdmin =>
      (_user?.role ?? '').toLowerCase() == 'admin';

  // =========================
  // SIGN IN
  // =========================
  Future<bool> signIn(String email, String password) async {
    return _runAuthTask(() async {
      final res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final userId = res.user?.id;
      if (userId == null) return false;

      await _fetchUser(userId);
      return true;
    });
  }

  // =========================
  // SIGN UP
  // =========================
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
  }) async {
    return _runAuthTask(() async {
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final userId = res.user?.id;

      // IMPORTANT: handles email verification mode
      if (userId == null) {
        _error = "Check your email to confirm your account.";
        notifyListeners();
        return false;
      }

      final profile = {
        'id': userId,
        'email': email.trim(),
        'role': 'student',
        'full_name': fullName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').upsert(profile);

      await _fetchUser(userId);
      return true;
    });
  }

  // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // =========================
  // SESSION CHECK
  // =========================
  Future<void> checkSession() async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      await _fetchUser(user.id);
    }
  }

  // =========================
  // FETCH USER PROFILE
  // =========================
  Future<void> _fetchUser(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        _error = "User profile not found.";
        _user = null;
      } else {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  // =========================
  // SHARED AUTH WRAPPER
  // =========================
  Future<bool> _runAuthTask(Future<bool> Function() task) async {
    _setLoading(true);
    _error = null;

    try {
      return await task();
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // STATE HELPER
  // =========================
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
