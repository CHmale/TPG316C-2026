// views/student/student_home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

// CHANGE: StatelessWidget → StatefulWidget
class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to call after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final appVM = context.watch<ApplicationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              // mounted works here because we're in State class
              if (mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.login);
              }
            },
          ),
        ],
      ),
      body: appVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${authVM.currentUser?.fullName ?? 'Student'}!',
                          ),
                          Text('Applications: ${appVM.applications.length}'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: appVM.applications.length,
                    itemBuilder: (context, index) {
                      final app = appVM.applications[index];
                      return ListTile(
                        title: Text(app.module1Name),
                        subtitle: Text('Status: ${app.status}'),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: appVM.applications.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteManager.applicationForm),
              icon: const Icon(Icons.add),
              label: const Text('Apply'),
            )
          : null,
    );
  }
}
