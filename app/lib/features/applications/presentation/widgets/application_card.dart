import 'package:flutter/material.dart';

import '../../domain/entities/application.dart';
import 'status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final bool isEmployer;
  final ValueChanged<String>? onStatusChanged;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.isEmployer,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEmployer
                      ? 'Applicant #${application.seekerId}'
                      : 'Job #${application.jobId ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Applied on: ${application.createdAt != null ? application.createdAt!.toLocal().toString().split(' ')[0] : 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (application.coverLetter != null &&
                application.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Cover Letter:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (isEmployer && onStatusChanged != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Update Status: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: application.status,
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'reviewed',
                        child: Text('Reviewed'),
                      ),
                      DropdownMenuItem(
                        value: 'accepted',
                        child: Text('Accepted'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null && val != application.status) {
                        onStatusChanged!(val);
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
