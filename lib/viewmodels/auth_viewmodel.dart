// viewmodels/auth_viewmodel.dart
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

  // Sign In
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

  // Sign Up
  // viewmodels/auth_viewmodel.dart
  // Update the signUp method

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
      // Step 1: Create auth user
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Step 2: Create user profile
        final userData = {
          'id': userId, // IMPORTANT: Include the ID matching auth.users
          'email': email.trim(),
          'role': 'student',
          'full_name': fullName,
          'student_number': studentNumber,
          'year_of_study': yearOfStudy,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Step 3: Insert into users table
        try {
          await _supabase.from('users').insert(userData);
        } catch (insertError) {
          // If insert fails, try to update instead (profile might already exist)
          print('Insert error, trying upsert: $insertError');
          await _supabase.from('users').upsert(userData);
        }

        await _loadUserProfile(userId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('SignUp error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Load user profile
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Check session on app start
  Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null && _currentUser == null) {
      await _loadUserProfile(session.user.id);
      notifyListeners();
    }
  }
}
