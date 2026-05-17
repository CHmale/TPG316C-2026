// views/admin/admin_dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';

// CHANGE: StatelessWidget → StatefulWidget
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

// ADD: State class where 'mounted' IS available
class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              // NOW 'mounted' works because we're in State class
              if (mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.login);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Admin Dashboard - Review Applications Here'),
      ),
    );
  }
}
