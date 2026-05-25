// MEMBERS:
// - Malejane HC 222025549
// - Mokhele KD 221037680
// - Manala E 222057458
// - Mohlohlo K 223010767
// - Modise LS 222021816
// - Nomankonya 216006365
// - Waeza LP 222041368
// ============================================================
// FILE: application_detail_view.dart
// DESCRIPTION: Application Details - View/Delete (Assignment 1.4)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../main.dart';

class ApplicationDetailView extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailView({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: CUTColors.primaryBlue,
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, child) {
          final application = appVM.getApplicationById(applicationId);

          if (application == null) {
            return const Center(child: Text('Application not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(application),
                const SizedBox(height: 16),
                _buildInfoCard('Personal Information', Icons.person, [
                  _buildInfoRow('Full Name', application.fullName),
                  _buildInfoRow('Student Number', application.studentNumber),
                  _buildInfoRow(
                    'Year of Study',
                    _getYearString(application.yearOfStudy),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard('Selected Modules', Icons.book, [
                  ...application.modules.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: CUTColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text('${entry.key + 1}')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value['name'] ?? '')),
                        ],
                      ),
                    );
                  }).toList(),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard('Supporting Document', Icons.attach_file, [
                  if (application.hasDocument)
                    Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: CUTColors.success,
                        ),
                        const SizedBox(width: 8),
                        const Text('Document attached'),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('View')),
                      ],
                    )
                  else
                    const Text(
                      'No document attached',
                      style: TextStyle(color: CUTColors.mediumGray),
                    ),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard('Eligibility', Icons.verified, [
                  _buildInfoRow(
                    'Meets Requirements',
                    application.meetsRequirements ? 'Yes' : 'No',
                  ),
                ]),
                if (application.adminComments != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildInfoCard('Admin Comments', Icons.comment, [
                      Text(application.adminComments!),
                    ]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(application) {
    Color color;
    String text;
    IconData icon;

    switch (application.status) {
      case 'approved':
        color = CUTColors.success;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = CUTColors.error;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        color = CUTColors.warning;
        text = 'Pending Review';
        icon = Icons.pending;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Status',
                    style: TextStyle(color: CUTColors.mediumGray),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text('Submitted: ${_formatDate(application.submittedAt)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: CUTColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  String _getYearString(int year) =>
      ['1st Year', '2nd Year', '3rd Year'][year - 1];
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
