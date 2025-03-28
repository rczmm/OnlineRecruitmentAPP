import 'package:flutter/material.dart';
import 'package:zhaopingapp/models/job.dart'; // Ensure correct path

class JobCardWidget extends StatelessWidget {
  final Job job;

  const JobCardWidget({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        // Add InkWell for tap effect
        borderRadius: BorderRadius.circular(8), // Match Card shape
        onTap: () {
          debugPrint('Tapped on job: ${job.title} (ID: ${job.id})');
          // Example navigation:
          // Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailPage(jobId: job.id)));
        },
        child: Padding(
          // Add padding inside InkWell
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Title and Salary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    job.salary,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      // Use primary color for salary
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Company Name and Location (Optional: Logo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Optional: Company Logo
                  // if (job.companyLogo.isNotEmpty) ...[
                  //   Image.network(job.companyLogo, width: 20, height: 20, errorBuilder: (_, __, ___) => const SizedBox()),
                  //   const SizedBox(width: 8),
                  // ],
                  Expanded(
                    // Allow company name to take space
                    child: Text(
                      job.company,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on_outlined,
                      size: 14, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    job.location
                        .split('·')
                        .first, // Show only city part for brevity
                    style:
                        textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Tags / Experience / Education (Use Wrap for tags)
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [
                  _buildInfoChip(context, job.workExperience),
                  _buildInfoChip(context, job.education),
                  // Display first few tags if needed
                  ...job.tags
                      .take(2)
                      .map((tag) => _buildInfoChip(context, tag)),
                ],
              ),
              const SizedBox(height: 8),

              // Row 4: HR Info (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Placeholder for HR avatar
                      CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.person,
                              size: 14, color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Text(
                        '${job.hrName} · HR',
                        // Assuming hrName is just the name
                        style: textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                  // Optional: Add favorite button or status indicator here
                  if (job.isFavorite)
                    Icon(Icons.favorite, color: Colors.redAccent, size: 18)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build small info chips
  Widget _buildInfoChip(BuildContext context, String text) {
    if (text.isEmpty) return const SizedBox.shrink(); // Don't show empty chips
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withAlpha(30),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: 11, // Make chips slightly smaller
            ),
      ),
    );
  }
}
