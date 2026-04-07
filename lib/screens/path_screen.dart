import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/health_milestone.dart';
import '../providers/analytics_provider.dart';
import '../providers/settings_provider.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final coachStart = settings.coachStartDate;
    final smokeFreeAsync = ref.watch(smokeFreeTimeProvider);
    final lastSmokeAsync = ref.watch(lastSmokeTimeProvider);

    if (coachStart == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Non-Smoker Path')),
        body: Center(
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
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Non-Smoker Path')),
      body: smokeFreeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (smokeFreeTime) {
          final lastSmoke = lastSmokeAsync.value;

          // Find furthest reached milestone based on smoke-free time
          int reachedIndex = -1;
          for (int i = healthMilestones.length - 1; i >= 0; i--) {
            if (smokeFreeTime >= healthMilestones[i].timeRequired) {
              reachedIndex = i;
              break;
            }
          }

          return Column(
            children: [
              // Smoke-free time header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 32, color: scheme.onPrimaryContainer),
                        const SizedBox(height: 8),
                        Text(
                          'Smoke-Free For',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatSmokeFreeTime(smokeFreeTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        if (lastSmoke != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Last cigarette: ${DateFormat('MMM d, h:mm a').format(lastSmoke)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Milestone list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: healthMilestones.length,
                  itemBuilder: (context, index) {
                    final milestone = healthMilestones[index];
                    final isReached = index <= reachedIndex;
                    final isCurrent = index == reachedIndex + 1;

                    double? progress;
                    if (isCurrent && index > 0) {
                      final prev =
                          healthMilestones[index - 1].timeRequired;
                      final target = milestone.timeRequired;
                      final range = target - prev;
                      final done = smokeFreeTime - prev;
                      if (range.inMinutes > 0) {
                        progress = (done.inMinutes / range.inMinutes)
                            .clamp(0.0, 1.0);
                      }
                    } else if (isCurrent && index == 0) {
                      progress = 1.0;
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
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatSmokeFreeTime(Duration d) {
    if (d.inDays >= 365) {
      final years = d.inDays ~/ 365;
      final days = d.inDays % 365;
      return '$years year${years > 1 ? "s" : ""} $days day${days != 1 ? "s" : ""}';
    }
    if (d.inDays >= 1) {
      final hours = d.inHours % 24;
      return '${d.inDays} day${d.inDays != 1 ? "s" : ""} ${hours}h';
    }
    if (d.inHours >= 1) {
      final mins = d.inMinutes % 60;
      return '${d.inHours}h ${mins}m';
    }
    return '${d.inMinutes}m';
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

    final iconColor = isReached ? milestone.color : scheme.outlineVariant;
    final textColor = isReached || isCurrent ? null : scheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 3,
                      color:
                          isReached ? milestone.color : scheme.outlineVariant,
                    ),
                  ),
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
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color:
                          isReached ? milestone.color : scheme.outlineVariant,
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
    if (d.inDays >= 365)
      return '${d.inDays ~/ 365} year';
    if (d.inDays >= 30)
      return '${d.inDays ~/ 30} month${d.inDays >= 60 ? "s" : ""}';
    if (d.inDays >= 7)
      return '${d.inDays ~/ 7} week${d.inDays >= 14 ? "s" : ""}';
    if (d.inDays >= 1) return '${d.inDays} day${d.inDays > 1 ? "s" : ""}';
    if (d.inHours >= 1)
      return '${d.inHours} hour${d.inHours > 1 ? "s" : ""}';
    return '${d.inMinutes} min';
  }
}
