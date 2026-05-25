// ============================================================
// FILE: login_view.dart
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
// FILE: login_view.dart
// DESCRIPTION: Login Screen - Authentication (Assignment 1.1)
// ============================================================
// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';
import '../../../main.dart';
import '../widgets/cut_gradient_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await authVM.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      if (authVM.isAdmin) {
        Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, RouteManager.studentHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CUTColors.primaryBlue, CUTColors.navyBlue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // CUT Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: CUTColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'CUT',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CUTColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Central University of Technology',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CUTColors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Student Assistant Management System',
                  style: TextStyle(fontSize: 14, color: CUTColors.white),
                ),
                const SizedBox(height: 48),

                // Login Card
                Container(
                  decoration: BoxDecoration(
                    color: CUTColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: CUTColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(color: CUTColors.mediumGray),
                          ),
                          const SizedBox(height: 32),

                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) =>
                                    v?.isEmpty == true ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator:
                                (v) =>
                                    v?.isEmpty == true
                                        ? 'Enter password'
                                        : null,
                          ),

                          if (authVM.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                authVM.errorMessage!,
                                style: const TextStyle(color: CUTColors.error),
                              ),
                            ),

                          const SizedBox(height: 24),

                          CUTGradientButton(
                            text: 'Login',
                            onPressed: () => _login(authVM),
                            isLoading: _isLoading,
                            icon: Icons.login,
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed:
                                () => Navigator.pushNamed(
                                  context,
                                  RouteManager.register,
                                ),
                            child: const Text(
                              'Create New Account',
                              style: TextStyle(color: CUTColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
