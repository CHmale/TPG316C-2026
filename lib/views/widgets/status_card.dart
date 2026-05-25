// ============================================================
// FILE: status_card.dart
// DESCRIPTION: Status card for applications
// ============================================================

import 'package:flutter/material.dart';
import '../../../main.dart';

class StatusCard extends StatelessWidget {
  final String status;
  final DateTime submittedAt;
  final DateTime? updatedAt;

  const StatusCard({
    super.key,
    required this.status,
    required this.submittedAt,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
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
        statusText = 'Pending Review';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, size: 28, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Status',
                    style: TextStyle(fontSize: 12, color: CUTColors.mediumGray),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted: ${_formatDate(submittedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CUTColors.mediumGray,
                    ),
                  ),
                  if (updatedAt != null)
                    Text(
                      'Last Updated: ${_formatDate(updatedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CUTColors.mediumGray,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
