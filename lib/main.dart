// ============================================================
// FILE: main.dart
// GROUP:W3M
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
// Entry point of CUT Student Assistant Management System.
// Initializes Supabase backend, sets up MVVM architecture,
// and configures CUT brand theming.
// ============================================================
// ASSIGNMENT REQUIREMENTS MET:
// - Unit 1: Material Design, Theming, Scaffold
// - Unit 2: MultiProvider, ChangeNotifierProvider
// - Unit 3: initialRoute, onGenerateRoute
// - Unit 5: Supabase.initialize()
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'routes/route_manager.dart';

// CUT Brand Colors
class CUTColors {
  static const Color primaryBlue = Color(0xFF0033A0);
  static const Color secondaryBlue = Color(0xFF0066CC);
  static const Color navyBlue = Color(0xFF002266);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFF0F2F5);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color darkGray = Color(0xFF343A40);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fkfovzbfyfmpqnskisbo.supabase.co',
    anonKey: 'sb_publishable_QK_sxz8kPr2Fo3m0NVIQRQ_7-VE5bO3',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CUT Student Assistant',
        theme: _buildCUTTheme(),
        initialRoute: RouteManager.login,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }

  ThemeData _buildCUTTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: CUTColors.primaryBlue,
      scaffoldBackgroundColor: CUTColors.offWhite,

      colorScheme: const ColorScheme.light(
        primary: CUTColors.primaryBlue,
        secondary: CUTColors.secondaryBlue,
        error: CUTColors.error,
        surface: CUTColors.white,
        onPrimary: CUTColors.white,
        onSurface: CUTColors.darkGray,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: CUTColors.primaryBlue,
        foregroundColor: CUTColors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CUTColors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CUTColors.primaryBlue,
          foregroundColor: CUTColors.white,
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CUTColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // FIXED: CardThemeData instead of CardTheme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: CUTColors.white,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: CUTColors.darkGray),
        bodyMedium: TextStyle(color: CUTColors.mediumGray),
      ),
    );
  }
}
