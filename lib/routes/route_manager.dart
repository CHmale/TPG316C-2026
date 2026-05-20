// ============================================================
// FILE: route_manager.dart
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
// Centralized route management for the application.
// Uses named routes with onGenerateRoute for dynamic navigation.
// ============================================================
// LEARNING OBJECTIVES COVERED:
// - Unit 3: Named routes (pushNamed, pop, pushReplacementNamed)
// - Unit 3: onGenerateRoute for dynamic route generation
// - Unit 3: Passing arguments between screens
// ============================================================

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
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeView());
      case applicationForm:
        final applicationId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ApplicationFormView(applicationId: applicationId),
        );
      case applicationDetail:
        final applicationId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailView(applicationId: applicationId!),
        );
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
