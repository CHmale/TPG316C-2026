// lib/views/admin/admin_dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<AdminViewModel>().fetchAllApplications();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: adminVM.isLoading && adminVM.allApplications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Statistics Cards
                  _buildStatsRow(adminVM),
                  const SizedBox(height: 16),

                  // Filter Chips
                  _buildFilterChips(),
                  const SizedBox(height: 16),

                  // Applications List
                  Expanded(
                    child: _getFilteredApplications(adminVM).isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _getFilteredApplications(adminVM).length,
                            itemBuilder: (context, index) {
                              final app = _getFilteredApplications(
                                adminVM,
                              )[index];
                              return _buildApplicationCard(adminVM, app);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  List _getFilteredApplications(AdminViewModel adminVM) {
    if (_filterStatus == 'all') {
      return adminVM.allApplications;
    }
    return adminVM.allApplications
        .where((app) => app.status == _filterStatus)
        .toList();
  }

  Widget _buildStatsRow(AdminViewModel adminVM) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total', adminVM.totalApplications, Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('Pending', adminVM.pendingCount, Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard('Approved', adminVM.approvedCount, Colors.green),
          const SizedBox(width: 12),
          _buildStatCard('Rejected', adminVM.rejectedCount, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
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
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No applications found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Students need to submit applications first',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIXED: Application Card - Shows REAL applicant data
  // ============================================================
  Widget _buildApplicationCard(AdminViewModel adminVM, application) {
    Color statusColor;
    String statusText;

    switch (application.status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            application.isApproved
                ? Icons.check
                : application.isRejected
                ? Icons.close
                : Icons.hourglass_empty,
            color: statusColor,
          ),
        ),
        // FIXED: Shows applicant's name, NOT admin's name
        title: Text(
          application.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student: ${application.studentNumber}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Module: ${application.module1Name}',
              style: const TextStyle(fontSize: 12),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application Details
                _buildDetailRow('Full Name', application.fullName),
                const Divider(),
                _buildDetailRow('Student Number', application.studentNumber),
                const Divider(),
                _buildDetailRow(
                  'Year of Study',
                  _getYearString(application.yearOfStudy),
                ),
                const Divider(),
                _buildDetailRow(
                  'Module 1',
                  '${_getLevelString(application.module1Level)} - ${application.module1Name}',
                ),
                if (application.hasSecondModule) ...[
                  const Divider(),
                  _buildDetailRow(
                    'Module 2',
                    '${_getLevelString(application.module2Level ?? '')} - ${application.module2Name ?? ''}',
                  ),
                ],
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
                if (application.updatedAt != null) ...[
                  const Divider(),
                  _buildDetailRow(
                    'Last Updated',
                    _formatDate(application.updatedAt!),
                  ),
                ],

                // Admin Comments
                if (application.adminComments != null &&
                    application.adminComments!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Comments:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(application.adminComments!),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Action Buttons (Only for pending applications)
                if (application.isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(
                            adminVM,
                            application.id,
                            true,
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(
                            adminVM,
                            application.id,
                            false,
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                // Delete Button (for all applications)
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(adminVM, application.id),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete Application'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(
    AdminViewModel adminVM,
    String applicationId,
    bool isApprove,
  ) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Application' : 'Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApprove
                  ? 'Are you sure you want to approve this application?'
                  : 'Please provide a reason for rejection:',
            ),
            if (!isApprove) ...[
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Rejection',
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason here...',
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
                success = await adminVM.approveApplication(applicationId);
              } else {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                success = await adminVM.rejectApplication(
                  applicationId,
                  reason: commentController.text.trim(),
                );
              }

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isApprove
                          ? 'Application approved!'
                          : 'Application rejected',
                    ),
                    backgroundColor: isApprove ? Colors.green : Colors.red,
                  ),
                );
                _loadData(); // Refresh the list
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AdminViewModel adminVM, String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await adminVM.deleteApplication(applicationId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData(); // Refresh the list
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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

  String _getLevelString(String level) {
    switch (level) {
      case 'first-year':
        return 'First Year';
      case 'second-year':
        return 'Second Year';
      case 'third-year':
        return 'Third Year';
      default:
        return level;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
