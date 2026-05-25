// MEMBERS:
// - Malejane HC 222025549
// - Mokhele KD 221037680
// - Manala E 222057458
// - Mohlohlo K 223010767
// - Modise LS 222021816
// - Nomankonya 216006365
// - Waeza LP 222041368
// ============================================================
// FILE: student_home_view.dart
// DESCRIPTION: Student Dashboard - View applications (Assignment 1.2)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';
import '../../main.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ApplicationViewModel>().fetchApplications();
  }

  void _logout(AuthViewModel authVM) async {
    await authVM.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }

  void _navigateToApplicationForm() {
    Navigator.pushNamed(
      context,
      RouteManager.applicationForm,
    ).then((_) => _loadData());
  }

  void _navigateToEditApplication(String id) {
    print('Editing application with ID: $id'); // Debug
    Navigator.pushNamed(
      context,
      RouteManager.applicationForm,
      arguments: id,
    ).then((_) => _loadData());
  }

  void _navigateToDetail(String id) {
    Navigator.pushNamed(context, RouteManager.applicationDetail, arguments: id);
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: CUTColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await context.read<ApplicationViewModel>().deleteApplication(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted'),
            backgroundColor: CUTColors.success,
          ),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final appVM = context.watch<ApplicationViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: CUTColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(authVM),
          ),
        ],
      ),
      body: appVM.isLoading && appVM.applications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: CUTColors.primaryBlue,
                            child: Text(
                              user?.fullName[0].toUpperCase() ?? 'S',
                              style: const TextStyle(
                                fontSize: 24,
                                color: CUTColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user?.fullName ?? 'Student'}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Student: ${user?.studentNumber ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: CUTColors.mediumGray,
                                  ),
                                ),
                                Text(
                                  'Year: ${_getYearString(user?.yearOfStudy ?? 1)}',
                                  style: const TextStyle(
                                    color: CUTColors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'My Applications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CUTColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (appVM.applications.isEmpty)
                    _buildEmptyState()
                  else
                    ...appVM.applications.map(
                      (app) => _buildApplicationCard(app),
                    ),
                ],
              ),
            ),
      floatingActionButton: appVM.applications.isEmpty
          ? FloatingActionButton(
              onPressed: _navigateToApplicationForm,
              backgroundColor: CUTColors.primaryBlue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: CUTColors.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Applications Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your application for a Student Assistant position',
              style: TextStyle(color: CUTColors.mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToApplicationForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: CUTColors.primaryBlue,
              ),
              child: const Text('Start Application'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(application) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (application.status) {
      case 'approved':
        statusColor = CUTColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = CUTColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = CUTColors.warning;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          '${application.moduleCount} Module(s) Selected',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submitted: ${_formatDate(application.submittedAt)}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: application.isPending
            ? PopupMenuButton(
                onSelected: (value) {
                  if (value == 'edit')
                    _navigateToEditApplication(application.id);
                  if (value == 'delete') _confirmDelete(application.id);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: CUTColors.error),
                    ),
                  ),
                ],
              )
            : null,
        onTap: () => _navigateToDetail(application.id),
      ),
    );
  }

  String _getYearString(int year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      default:
        return '$year Year';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
