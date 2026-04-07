import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_milestone.dart';
import '../providers/settings_provider.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final coachStart = settings.coachStartDate;
    final Duration elapsed;
    if (coachStart != null) {
      elapsed = DateTime.now().difference(coachStart);
    } else {
      elapsed = Duration.zero;
    }

    // Find furthest reached milestone
    int reachedIndex = -1;
    for (int i = healthMilestones.length - 1; i >= 0; i--) {
      if (elapsed >= healthMilestones[i].timeRequired) {
        reachedIndex = i;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Non-Smoker Path')),
      body: coachStart == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, size: 48, color: scheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Switch to Coach Mode to start your path',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: healthMilestones.length,
              itemBuilder: (context, index) {
                final milestone = healthMilestones[index];
                final isReached = index <= reachedIndex;
                final isCurrent = index == reachedIndex + 1;

                // Progress to next milestone
                double? progress;
                if (isCurrent && index > 0) {
                  final prev = healthMilestones[index - 1].timeRequired;
                  final target = milestone.timeRequired;
                  final range = target - prev;
                  final done = elapsed - prev;
                  if (range.inMinutes > 0) {
                    progress =
                        (done.inMinutes / range.inMinutes).clamp(0.0, 1.0);
                  }
                }

                return _MilestoneRow(
                  milestone: milestone,
                  isReached: isReached,
                  isCurrent: isCurrent,
                  progress: progress,
                  isFirst: index == 0,
                  isLast: index == healthMilestones.length - 1,
                );
              },
            ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final HealthMilestone milestone;
  final bool isReached;
  final bool isCurrent;
  final double? progress;
  final bool isFirst;
  final bool isLast;

  const _MilestoneRow({
    required this.milestone,
    required this.isReached,
    required this.isCurrent,
    required this.progress,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final iconColor =
        isReached ? milestone.color : scheme.outlineVariant;
    final textColor =
        isReached || isCurrent ? null : scheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: isReached
                          ? milestone.color
                          : scheme.outlineVariant,
                    ),
                  ),

                // Circle / icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReached
                        ? milestone.color.withAlpha(30)
                        : scheme.surfaceContainerHighest,
                    border: Border.all(
                      color: iconColor,
                      width: isCurrent ? 3 : 2,
                    ),
                  ),
                  child: Icon(milestone.icon, size: 20, color: iconColor),
                ),

                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: isReached
                          ? milestone.color
                          : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (isReached)
                        Icon(Icons.check_circle,
                            size: 18, color: milestone.color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isReached || isCurrent
                          ? scheme.onSurfaceVariant
                          : scheme.outline,
                    ),
                  ),
                  if (isCurrent && progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress!,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: milestone.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress! * 100).toInt()}% there',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: milestone.color,
                      ),
                    ),
                  ],
                  Text(
                    _formatDuration(milestone.timeRequired),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return 'Day 0';
    if (d.inDays >= 365) return '${d.inDays ~/ 365} year';
    if (d.inDays >= 30) return '${d.inDays ~/ 30} month${d.inDays >= 60 ? "s" : ""}';
    if (d.inDays >= 7) return '${d.inDays ~/ 7} week${d.inDays >= 14 ? "s" : ""}';
    if (d.inDays >= 1) return '${d.inDays} day${d.inDays > 1 ? "s" : ""}';
    if (d.inHours >= 1) return '${d.inHours} hour${d.inHours > 1 ? "s" : ""}';
    return '${d.inMinutes} min';
  }
}
