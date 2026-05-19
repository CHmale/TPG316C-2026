// lib/routes/route_manager.dart
import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/student/student_home_view.dart';
import '../views/student/application_form_view.dart';
import '../views/student/application_detail_view.dart';
import '../views/admin/admin_dashboard_view.dart';

class RouteManager {
  static const String login = '/login';
  static const String register = '/register';
  static const String studentHome = '/student/home';
  static const String applicationForm = '/application/form';
  static const String applicationDetail = '/application/detail';
  static const String adminDashboard = '/admin/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case login:
          return _createRoute(const LoginView(), settings);

        case register:
          return _createRoute(const RegisterView(), settings);

        case studentHome:
          return _createRoute(const StudentHomeView(), settings);

        case applicationForm:
          final applicationId = settings.arguments as String?;
          return _createRoute(
            ApplicationFormView(applicationId: applicationId),
            settings,
          );

        case applicationDetail:
          final applicationId = settings.arguments as String?;
          if (applicationId == null || applicationId.isEmpty) {
            return _errorRoute('Application ID is required');
          }
          return _createRoute(
            ApplicationDetailView(applicationId: applicationId),
            settings,
          );

        case adminDashboard:
          return _createRoute(const AdminDashboardView(), settings);

        default:
          return _errorRoute('Route ${settings.name} not found');
      }
    } catch (e) {
      return _errorRoute('Error navigating: $e');
    }
  }

  static Route<dynamic> _createRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: ThemeData.light().textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(
                  Navigator.of(_ as BuildContext),
                  (route) => route.isFirst,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      settings: const RouteSettings(name: '/error'),
    );
  }
}
