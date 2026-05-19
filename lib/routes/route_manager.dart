// lib/routes/route_manager.dart
import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/student/student_home_view.dart';
import '../views/student/application_form_view.dart';
import '../views/student/application_detail_view.dart';
import '../views/admin/admin_dashboard_view.dart';

// 🎨 Custom route transition colors
class RouteTransitionColors {
  static const Color primary = Color(0xFF6C63FF);     // Modern Purple
  static const Color secondary = Color(0xFFFF6584);   // Coral Pink
  static const Color accent = Color(0xFF00D2FF);      // Cyan
}

class RouteManager {
  static const String login = '/login';
  static const String register = '/register';
  static const String studentHome = '/student/home';
  static const String applicationForm = '/application/form';
  static const String applicationDetail = '/application/detail';
  static const String adminDashboard = '/admin/dashboard';
  
  // Navigation helper methods with named routes
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<T?> pushReplacementNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void pop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) {
    Navigator.pop(context, result);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildTransition(
          page: const LoginView(),
          settings: settings,
          transitionType: RouteTransition.fade,
        );

      case register:
        return _buildTransition(
          page: const RegisterView(),
          settings: settings,
          transitionType: RouteTransition.slideUp,
        );

      case studentHome:
        return _buildTransition(
          page: const StudentHomeView(),
          settings: settings,
          transitionType: RouteTransition.fadeScale,
        );

      case applicationForm:
        final applicationId = settings.arguments as String?;
        return _buildTransition(
          page: ApplicationFormView(applicationId: applicationId),
          settings: settings,
          transitionType: RouteTransition.slideRight,
        );

      case applicationDetail:
        final applicationId = settings.arguments as String?;
        if (applicationId == null) {
          return _buildErrorRoute(
            'Application ID not provided',
            settings,
          );
        }
        return _buildTransition(
          page: ApplicationDetailView(applicationId: applicationId),
          settings: settings,
          transitionType: RouteTransition.fade,
        );

      case adminDashboard:
        return _buildTransition(
          page: const AdminDashboardView(),
          settings: settings,
          transitionType: RouteTransition.scale,
        );

      default:
        return _buildErrorRoute(
          'Route ${settings.name} not found',
          settings,
        );
    }
  }
  
  // Helper method to build transitions
  static PageRoute _buildTransition({
    required Widget page,
    required RouteSettings settings,
    required RouteTransition transitionType,
  }) {
    return CustomPageRoute(
      page: page,
      settings: settings,
      transitionType: transitionType,
    );
  }
  
  // Error route with better design
  static MaterialPageRoute _buildErrorRoute(String message, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RouteTransitionColors.primary.withOpacity(0.1),
                  RouteTransitionColors.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RouteTransitionColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: RouteTransitionColors.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Navigation Error',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RouteTransitionColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom page route with enhanced transitions
enum RouteTransition {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  fadeScale,
  rotate,
  size,
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final RouteTransition transitionType;
  
  CustomPageRoute({
    required this.page,
    required RouteSettings settings,
    this.transitionType = RouteTransition.fade,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case RouteTransition.fade:
          return _buildFadeTransition(animation, child);
        case RouteTransition.slideRight:
          return _buildSlideTransition(animation, child, Offset(1.0, 0.0));
        case RouteTransition.slideLeft:
          return _buildSlideTransition(animation, child, Offset(-1.0, 0.0));
        case RouteTransition.slideUp:
          return _buildSlideTransition(animation, child, Offset(0.0, 1.0));
        case RouteTransition.slideDown:
          return _buildSlideTransition(animation, child, Offset(0.0, -1.0));
        case RouteTransition.scale:
          return _buildScaleTransition(animation, child);
        case RouteTransition.fadeScale:
          return _buildFadeScaleTransition(animation, child);
        case RouteTransition.rotate:
          return _buildRotateTransition(animation, child);
        case RouteTransition.size:
          return _buildSizeTransition(animation, child);
      }
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
  );
  
  // Fade transition
  Widget _buildFadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  // Slide transition
  Widget _buildSlideTransition(
    Animation<double> animation,
    Widget child,
    Offset offset,
  ) {
    var begin = offset;
    var end = Offset.zero;
    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
  
  // Scale transition
  Widget _buildScaleTransition(Animation<double> animation, Widget child) {
    var tween = Tween(begin: 0.8, end: 1.0);
    var scaleAnimation = animation.drive(tween);
    
    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  // Combined fade and scale transition
  Widget _buildFadeScaleTransition(Animation<double> animation, Widget child) {
    var scaleTween = Tween(begin: 0.9, end: 1.0);
    var scaleAnimation = animation.drive(scaleTween);
    
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
  
  // Rotate transition
  Widget _buildRotateTransition(Animation<double> animation, Widget child) {
    var rotateTween = Tween(begin: -0.1, end: 0.0);
    var rotateAnimation = animation.drive(rotateTween);
    
    return RotationTransition(
      turns: rotateAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  // Size transition (grows from center)
  Widget _buildSizeTransition(Animation<double> animation, Widget child) {
    var sizeTween = Tween(begin: 0.0, end: 1.0);
    var sizeAnimation = animation.drive(sizeTween);
    
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: 0,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

// 🎯 Optional: Hero Dialog Route for modal-style navigation
class HeroDialogRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  HeroDialogRoute({
    required this.page,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curveTween = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      var scaleTween = Tween(begin: 0.8, end: 1.0);
      var scaleAnimation = scaleTween.animate(curveTween);
      
      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: curveTween,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    opaque: false,
    barrierColor: Colors.black54,
  }
  
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

// 🎯 Optional: Navigation Observer for tracking routes
class RouteObserverManager extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('Route pushed: ${route.settings.name}');
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('Route popped: ${route.settings.name}');
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    print('Route removed: ${route.settings.name}');
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}

// Extension on BuildContext for easier navigation
extension NavigationExtension on BuildContext {
  void pushNamed(String routeName, {Object? arguments}) {
    RouteManager.pushNamed(this, routeName, arguments: arguments);
  }
  
  void pushReplacementNamed(String routeName, {Object? arguments}) {
    RouteManager.pushReplacementNamed(this, routeName, arguments: arguments);
  }
  
  void pushAndRemoveUntil(String routeName, {Object? arguments}) {
    RouteManager.pushAndRemoveUntil(this, routeName, arguments: arguments);
  }
  
  void pop<T extends Object?>([T? result]) {
    RouteManager.pop(this, result);
  }
  
  bool get canPop => Navigator.canPop(this);
  
  Future<T?> showHeroDialog<T>(Widget page) {
    return Navigator.of(this).push<T>(
      HeroDialogRoute<T>(
        page: page,
      ),
    );
  }
}
