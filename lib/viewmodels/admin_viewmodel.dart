import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

//  Custom color scheme for authentication states
class AuthColors {
  static const Color primary = Color(0xFF6C63FF);     // Modern Purple
  static const Color secondary = Color(0xFFFF6584);   // Coral Pink
  static const Color success = Color(0xFF00B894);     // Mint Green
  static const Color error = Color(0xFFD63031);       // Deep Red
  static const Color warning = Color(0xFFFDCB6E);     // Golden Yellow
  static const Color info = Color(0xFF0984E3);        // Bright Blue
  static const Color textPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray
}

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _loading = false;
  String? _error;
  String? _successMessage;
  String? _operationType;
  
  // Additional state for better UX
  bool _emailVerificationRequired = false;
  String? _lastUsedEmail;
  DateTime? _lastSignInAttempt;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get operationType => _operationType;
  bool get emailVerificationRequired => _emailVerificationRequired;
  String? get lastUsedEmail => _lastUsedEmail;
  
  // Computed properties for UI
  bool get isLoggedIn => _supabase.auth.currentUser != null;
  
  bool get isAdmin => (_user?.role ?? '').toLowerCase() == 'admin';
  
  bool get isStudent => (_user?.role ?? '').toLowerCase() == 'student';
  
  String get userDisplayName {
    if (_user?.fullName != null && _user!.fullName.isNotEmpty) {
      return _user!.fullName;
    }
    return _user?.email?.split('@').first ?? 'User';
  }
  
  String get userInitial {
    final name = userDisplayName;
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
  
  Color getUserRoleColor() {
    if (isAdmin) return AuthColors.primary;
    if (isStudent) return AuthColors.success;
    return AuthColors.info;
  }
  
  bool get canResendVerification {
    if (_lastSignInAttempt == null) return true;
    final difference = DateTime.now().difference(_lastSignInAttempt!);
    return difference.inSeconds > 60; // Can resend after 60 seconds
  }
  
  String getTimeSinceLastAttempt() {
    if (_lastSignInAttempt == null) return '';
    final difference = DateTime.now().difference(_lastSignInAttempt!);
    if (difference.inSeconds < 60) {
      return '${60 - difference.inSeconds} seconds';
    }
    return '';
  }

  // =========================
  // SIGN IN
  // =========================
  Future<bool> signIn(String email, String password) async {
    _lastUsedEmail = email.trim();
    _lastSignInAttempt = DateTime.now();
    
    return _runAuthTask(
      operation: 'Signing in...',
      task: () async {
        try {
          final res = await _supabase.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );

          final userId = res.user?.id;
          if (userId == null) {
            _error = 'Unable to sign in. Please check your credentials.';
            return false;
          }

          // Check if email is confirmed
          final user = res.user;
          if (user != null && !user.emailConfirmedAt.isNotEmpty) {
            _emailVerificationRequired = true;
            _error = 'Please verify your email before signing in. Check your inbox.';
            await _supabase.auth.signOut();
            return false;
          }

          _emailVerificationRequired = false;
          await _fetchUser(userId);
          _successMessage = 'Welcome back, ${_user?.fullName ?? 'User'}!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
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
    _lastUsedEmail = email.trim();
    
    return _runAuthTask(
      operation: 'Creating your account...',
      task: () async {
        try {
          // Validate inputs before attempting signup
          final validationError = _validateSignUpInputs(
            email: email,
            password: password,
            fullName: fullName,
            studentNumber: studentNumber,
            yearOfStudy: yearOfStudy,
          );
          
          if (validationError != null) {
            _error = validationError;
            return false;
          }
          
          final res = await _supabase.auth.signUp(
            email: email.trim(),
            password: password,
          );

          final userId = res.user?.id;

          // Handle email verification mode
          if (userId == null || res.user?.emailConfirmedAt.isEmpty == true) {
            _emailVerificationRequired = true;
            _successMessage = "Verification email sent! Please check your inbox to confirm your account.";
            return false;
          }

          final profile = {
            'id': userId,
            'email': email.trim(),
            'role': 'student',
            'full_name': fullName.trim(),
            'student_number': studentNumber.trim(),
            'year_of_study': yearOfStudy,
            'created_at': DateTime.now().toIso8601String(),
          };

          await _supabase.from('users').upsert(profile);
          await _fetchUser(userId);
          _successMessage = 'Account created successfully! Welcome to Student Assistant App!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
  }

  // =========================
  // RESEND VERIFICATION EMAIL
  // =========================
  Future<bool> resendVerificationEmail() async {
    if (_lastUsedEmail == null) {
      _error = 'No email address found. Please try signing up again.';
      return false;
    }
    
    if (!canResendVerification) {
      _error = 'Please wait ${getTimeSinceLastAttempt()} before requesting another email.';
      return false;
    }
    
    _setLoading(true);
    _error = null;
    _operationType = 'Sending verification email...';
    
    try {
      await _supabase.auth.resend(
        type: ResendType.signup,
        email: _lastUsedEmail!,
      );
      _successMessage = 'Verification email resent! Please check your inbox.';
      _lastSignInAttempt = DateTime.now();
      return true;
    } catch (e) {
      _error = 'Failed to resend verification email: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
      _operationType = null;
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================
  Future<bool> resetPassword(String email) async {
    return _runAuthTask(
      operation: 'Sending reset link...',
      task: () async {
        try {
          await _supabase.auth.resetPasswordForEmail(email.trim());
          _successMessage = 'Password reset link sent to your email!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
  }

  // =========================
  // UPDATE PASSWORD
  // =========================
  Future<bool> updatePassword(String newPassword) async {
    return _runAuthTask(
      operation: 'Updating password...',
      task: () async {
        try {
          await _supabase.auth.updateUser(
            UserAttributes(password: newPassword),
          );
          _successMessage = 'Password updated successfully!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
  }

  // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _supabase.auth.signOut();
      _user = null;
      _emailVerificationRequired = false;
      _successMessage = 'You have been signed out successfully.';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE USER PROFILE
  // =========================
  Future<bool> updateUserProfile({
    String? fullName,
    String? studentNumber,
    int? yearOfStudy,
  }) async {
    if (_user == null) {
      _error = 'No user logged in';
      return false;
    }
    
    return _runAuthTask(
      operation: 'Updating profile...',
      task: () async {
        try {
          final updates = <String, dynamic>{};
          if (fullName != null) updates['full_name'] = fullName.trim();
          if (studentNumber != null) updates['student_number'] = studentNumber.trim();
          if (yearOfStudy != null) updates['year_of_study'] = yearOfStudy;
          updates['updated_at'] = DateTime.now().toIso8601String();
          
          await _supabase
              .from('users')
              .update(updates)
              .match({'id': _user!.id});
          
          await _fetchUser(_user!.id);
          _successMessage = 'Profile updated successfully!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
  }

  // =========================
  // DELETE ACCOUNT
  // =========================
  Future<bool> deleteAccount() async {
    if (_user == null) {
      _error = 'No user logged in';
      return false;
    }
    
    return _runAuthTask(
      operation: 'Deleting account...',
      task: () async {
        try {
          // Delete user profile from users table
          await _supabase.from('users').delete().match({'id': _user!.id});
          
          // Delete auth user (requires admin privileges or edge function)
          // For now, we'll just sign out after profile deletion
          await _supabase.auth.signOut();
          _user = null;
          _successMessage = 'Account deleted successfully. We\'re sad to see you go!';
          return true;
        } catch (e) {
          _handleAuthError(e);
          return false;
        }
      },
    );
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
        _error = "User profile not found. Please contact support.";
        _user = null;
      } else {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // =========================
  // VALIDATION HELPERS
  // =========================
  String? _validateSignUpInputs({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
  }) {
    if (email.isEmpty) return 'Email address is required';
    if (!email.contains('@')) return 'Please enter a valid email address';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (fullName.isEmpty) return 'Full name is required';
    if (studentNumber.isEmpty) return 'Student number is required';
    if (yearOfStudy < 1 || yearOfStudy > 4) {
      return 'Year of study must be between 1 and 4';
    }
    return null;
  }
  
  void _handleAuthError(dynamic e) {
    final errorString = e.toString().toLowerCase();
    
    if (errorString.contains('invalid login credentials')) {
      _error = 'Invalid email or password. Please try again.';
    } else if (errorString.contains('email not confirmed')) {
      _emailVerificationRequired = true;
      _error = 'Please verify your email address before signing in.';
    } else if (errorString.contains('user already registered')) {
      _error = 'An account with this email already exists. Please sign in instead.';
    } else if (errorString.contains('weak password')) {
      _error = 'Password is too weak. Please use a stronger password.';
    } else {
      _error = e.toString();
    }
  }

  // =========================
  // SHARED AUTH WRAPPER
  // =========================
  Future<bool> _runAuthTask({
    required String operation,
    required Future<bool> Function() task,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    _operationType = operation;

    try {
      return await task();
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
      _operationType = null;
    }
  }

  // =========================
  // STATE HELPERS
  // =========================
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
  
  void clearVerificationRequired() {
    _emailVerificationRequired = false;
    notifyListeners();
  }
}
