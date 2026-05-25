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
// ============================================================
// DESCRIPTION:
// Authentication ViewModel - manages user authentication,
// session state, and role-based routing.
// ============================================================
// LEARNING OBJECTIVES COVERED:
// - Unit 2: ViewModel extends ChangeNotifier
// - Unit 2: Private Model instance, public getters
// - Unit 2: notifyListeners() for UI updates
// - Unit 5: Supabase Authentication (signUp, signIn, signOut)
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _supabase.auth.currentSession != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  // ============================================================
  // SIGN IN - Assignment 1.1
  // ============================================================
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
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

  // ============================================================
  // SIGN UP - Assignment 1.1
  // ============================================================
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        final userData = {
          'id': userId,
          'email': email.trim(),
          'role': 'student',
          'full_name': fullName,
          'student_number': studentNumber,
          'year_of_study': yearOfStudy,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userData);
        await _loadUserProfile(userId);
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

  // ============================================================
  // SIGN OUT
  // ============================================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null && _currentUser == null) {
      await _loadUserProfile(session.user.id);
      notifyListeners();
    }
  }
}
