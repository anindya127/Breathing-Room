import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/coach_provider.dart';
import '../../providers/settings_provider.dart';

/// Bottom sheet showing the whole staircase, with the current phase marked.
class PlanSheet extends ConsumerWidget {
  const PlanSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const PlanSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final phases = ref.watch(planProvider);
    final settings = ref.watch(settingsProvider);
    final start = settings.coachStartDate;
    final current = start == null
        ? 0
        : currentPhaseIndex(
            reductionDays: settings.reductionDays,
            startDate: start,
            now: DateTime.now(),
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your plan', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'One step every ${settings.reductionDays} '
              '${settings.reductionDays == 1 ? 'day' : 'days'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (phases.isEmpty)
              Text(
                'No plan yet — set your baseline and step size first.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: phases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final phase = phases[i];
                    final isCurrent = i == current;
                    final isPast = i < current;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? scheme.primary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrent
                            ? Border.all(color: scheme.primary, width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              phase.dayLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isPast
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              phase.isFinal
                                  ? 'Smoke-free'
                                  : '${phase.limit} a day',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight:
                                    isCurrent ? FontWeight.w600 : FontWeight.w400,
                                color: _phaseColor(phase, isPast, scheme),
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Text(
                              'now',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _phaseColor(PlanPhase phase, bool isPast, ColorScheme scheme) {
    if (phase.isFinal) return scheme.primary;
    return isPast ? scheme.onSurfaceVariant : scheme.onSurface;
  }
}
