// routes/route_manager.dart
import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/student/student_home_view.dart';
import '../views/student/application_form_view.dart';
import '../views/admin/admin_dashboard_view.dart';

class RouteManager {
  static const String login = '/login';
  static const String register = '/register';
  static const String studentHome = '/student/home';
  static const String applicationForm = '/application/form';
  static const String adminDashboard = '/admin/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeView());
      case applicationForm:
        return MaterialPageRoute(builder: (_) => const ApplicationFormView());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}
