import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

// Custom error types
enum AuthErrorType {
  none,
  network,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  serverError,
  unknown,
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final AuthErrorType errorType;
  final bool isSessionValid;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.errorType = AuthErrorType.none,
    this.isSessionValid = true,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    AuthErrorType? errorType,
    bool? isSessionValid,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
      isSessionValid: isSessionValid ?? this.isSessionValid,
    );
  }
}

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AuthState _state = const AuthState();

  AuthState get state => _state;
  UserModel? get user => _state.user;
  bool get isLoading => _state.isLoading;
  String? get error => _state.errorMessage;
  AuthErrorType get errorType => _state.errorType;
  bool get isLoggedIn => _supabase.auth.currentSession != null;
  bool get isAdmin => _state.user?.role.toLowerCase() == 'admin';

  // Sign In with validation
  Future<bool> signIn(String email, String password) async {
    if (!_validateEmail(email)) {
      _setError('Invalid email format', AuthErrorType.invalidCredentials);
      return false;
    }
    
    if (!_validatePassword(password)) {
      _setError('Password must be at least 6 characters', AuthErrorType.weakPassword);
      return false;
    }

    return _runAuthTask(() async {
      try {
        final res = await _supabase.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );

        final userId = res.user?.id;
        if (userId == null) {
          _setError('User ID not found', AuthErrorType.serverError);
          return false;
        }

        await _fetchUser(userId);
        return true;
      } on AuthException catch (e) {
        _handleAuthException(e);
        return false;
      }
    });
  }

  // Sign Up with validation
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
  }) async {
    final errors = <String, String>{};
    
    if (!_validateEmail(email)) errors['email'] = 'Invalid email format';
    if (!_validatePassword(password)) errors['password'] = 'Password too weak';
    if (fullName.isEmpty) errors['fullName'] = 'Full name required';
    if (studentNumber.isEmpty) errors['studentNumber'] = 'Student number required';
    if (yearOfStudy < 1 || yearOfStudy > 6) errors['yearOfStudy'] = 'Invalid year';
    
    if (errors.isNotEmpty) {
      _setError(errors.values.join(', '), AuthErrorType.invalidCredentials);
      return {'success': false, 'errors': errors};
    }

    final result = await _runAuthTaskWithResult(() async {
      try {
        final res = await _supabase.auth.signUp(
          email: email.trim(),
          password: password,
        );

        final userId = res.user?.id;
        if (userId == null) {
          _setError('Sign up failed', AuthErrorType.serverError);
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
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').upsert(profile);
        await _fetchUser(userId);
        return true;
      } on AuthException catch (e) {
        _handleAuthException(e);
        return false;
      }
    });

    return {'success': result, 'errors': {}};
  }

  // Sign Out with cleanup
  Future<void> signOut() async {
    await _runSafeOperation(() async {
      await _supabase.auth.signOut();
      _state = const AuthState();
      notifyListeners();
    });
  }

  // Session check with refresh
  Future<bool> checkSession() async {
    final session = _supabase.auth.currentSession;
    
    if (session != null) {
      final user = await _fetchUser(session.user.id);
      return user != null;
    }
    
    return false;
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_state.user != null) {
      await _fetchUser(_state.user!.id);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_state.user == null) return false;
    
    return _runAuthTask(() async {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _state.user!.id);
      
      await _fetchUser(_state.user!.id);
      return true;
    });
  }

  // Helper methods
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  void _handleAuthException(AuthException e) {
    final message = e.message;
    
    if (message.contains('Invalid login credentials')) {
      _setError('Invalid email or password', AuthErrorType.invalidCredentials);
    } else if (message.contains('User already registered')) {
      _setError('Email already in use', AuthErrorType.emailAlreadyInUse);
    } else if (message.contains('Password should be at least 6 characters')) {
      _setError('Password too weak', AuthErrorType.weakPassword);
    } else {
      _setError(message, AuthErrorType.unknown);
    }
  }

  void _setError(String message, AuthErrorType type) {
    _state = _state.copyWith(
      errorMessage: message,
      errorType: type,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<UserModel?> _fetchUser(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final user = UserModel.fromJson(data);
        _state = _state.copyWith(
          user: user,
          errorMessage: null,
          errorType: AuthErrorType.none,
        );
        notifyListeners();
        return user;
      }
    } catch (e) {
      _setError(e.toString(), AuthErrorType.serverError);
    }
    
    return null;
  }

  Future<bool> _runAuthTask(Future<bool> Function() task) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      return await task();
    } catch (e) {
      _setError(e.toString(), AuthErrorType.unknown);
      return false;
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<bool> _runAuthTaskWithResult(Future<bool> Function() task) async {
    return _runAuthTask(task);
  }

  Future<void> _runSafeOperation(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      debugPrint('Auth operation failed: $e');
    }
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null, errorType: AuthErrorType.none);
    notifyListeners();
  }
}
