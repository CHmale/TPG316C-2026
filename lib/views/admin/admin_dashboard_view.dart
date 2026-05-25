// MEMBERS:
// - Malejane HC 222025549
// - Mokhele KD 221037680
// - Manala E 222057458
// - Mohlohlo K 223010767
// - Modise LS 222021816
// - Nomankonya 216006365
// - Waeza LP 222041368
// ============================================================
// FILE: admin_dashboard_view.dart
// DESCRIPTION: Admin Dashboard - Review Applications (Assignment 2.1)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';
import '../../main.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<AdminViewModel>().fetchAllApplications();
  }

  List _getFiltered(AdminViewModel vm) {
    if (_filter == 'all') return vm.allApplications;
    return vm.allApplications.where((app) => app.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: CUTColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              if (mounted)
                Navigator.pushReplacementNamed(context, RouteManager.login);
            },
          ),
        ],
      ),
      body:
          adminVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Statistics Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Total',
                          adminVM.totalApplications,
                          CUTColors.primaryBlue,
                        ),
                        _buildStatCard(
                          'Pending',
                          adminVM.pendingCount,
                          CUTColors.warning,
                        ),
                        _buildStatCard(
                          'Approved',
                          adminVM.approvedCount,
                          CUTColors.success,
                        ),
                        _buildStatCard(
                          'Rejected',
                          adminVM.rejectedCount,
                          CUTColors.error,
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Approved', 'approved'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Applications List
                  Expanded(
                    child:
                        _getFiltered(adminVM).isEmpty
                            ? const Center(child: Text('No applications'))
                            : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _getFiltered(adminVM).length,
                              itemBuilder: (context, index) {
                                final app = _getFiltered(adminVM)[index];
                                return _buildApplicationCard(adminVM, app);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: CUTColors.lightGray,
      selectedColor: CUTColors.primaryBlue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _filter == value ? CUTColors.primaryBlue : CUTColors.darkGray,
      ),
    );
  }

  Widget _buildApplicationCard(AdminViewModel adminVM, application) {
    Color statusColor;
    String statusText;

    switch (application.status) {
      case 'approved':
        statusColor = CUTColors.success;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = CUTColors.error;
        statusText = 'Rejected';
        break;
      default:
        statusColor = CUTColors.warning;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            application.isApproved
                ? Icons.check
                : (application.isRejected
                    ? Icons.close
                    : Icons.hourglass_empty),
            color: statusColor,
          ),
        ),
        title: Text(
          application.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Student: ${application.studentNumber} | ${application.moduleCount} module(s)',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Student Number', application.studentNumber),
                const Divider(),
                _buildDetailRow(
                  'Year of Study',
                  _getYearString(application.yearOfStudy),
                ),
                const Divider(),
                const Text(
                  'Selected Modules:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...application.modules.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: CUTColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text('${entry.key + 1}')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.value['name'] ?? '')),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                _buildDetailRow(
                  'Meets Requirements',
                  application.meetsRequirements ? 'Yes' : 'No',
                ),
                const Divider(),
                _buildDetailRow(
                  'Submitted',
                  _formatDate(application.submittedAt),
                ),
                if (application.hasDocument) ...[
                  const Divider(),
                  _buildDetailRow('Document', 'Attached'),
                ],
                if (application.adminComments != null) ...[
                  const Divider(),
                  _buildDetailRow('Admin Comments', application.adminComments!),
                ],
                const SizedBox(height: 16),

                if (application.isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _showApprovalDialog(
                                adminVM,
                                application.id,
                                true,
                              ),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CUTColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _showApprovalDialog(
                                adminVM,
                                application.id,
                                false,
                              ),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CUTColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(adminVM, application.id),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Application'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CUTColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: CUTColors.mediumGray),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showApprovalDialog(
    AdminViewModel adminVM,
    String id,
    bool isApprove,
  ) async {
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isApprove ? 'Approve Application' : 'Reject Application',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApprove ? 'Confirm approval?' : 'Enter rejection reason:',
                ),
                if (!isApprove) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Reason for rejection',
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  bool success;
                  if (isApprove) {
                    success = await adminVM.approveApplication(id);
                  } else {
                    if (commentController.text.isEmpty) return;
                    success = await adminVM.rejectApplication(
                      id,
                      reason: commentController.text,
                    );
                  }
                  if (success) {
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isApprove
                              ? 'Application approved'
                              : 'Application rejected',
                        ),
                        backgroundColor:
                            isApprove ? CUTColors.success : CUTColors.error,
                      ),
                    );
                  }
                },
                child: Text(isApprove ? 'Approve' : 'Reject'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(AdminViewModel adminVM, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Application'),
            content: const Text('Are you sure?'),
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
      await adminVM.deleteApplication(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application deleted'),
          backgroundColor: CUTColors.success,
        ),
      );
    }
  }

  String _getYearString(int year) =>
      ['1st Year', '2nd Year', '3rd Year'][year - 1];
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
