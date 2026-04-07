import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../providers/analytics_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/smoke_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final sym = currencySymbol(settings.currency);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final todaySpent = ref.watch(todaySpentProvider);
    final todaySaved = ref.watch(todayMoneySavedProvider);
    final totalSpent = ref.watch(totalSpentProvider).value ?? 0.0;
    final totalSaved = ref.watch(totalSavedProvider);
    final totalSmokes = ref.watch(totalSmokesProvider).value ?? 0;
    final isCoach = settings.mode == TrackingMode.coach;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Big spent card
          Card(
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.local_fire_department,
                      size: 36, color: scheme.onErrorContainer),
                  const SizedBox(height: 8),
                  Text('Total Spent on Smoking',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onErrorContainer,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '$sym ${totalSpent.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$totalSmokes cigarettes total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Saved card (coach mode)
          if (isCoach) ...[
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.savings,
                        size: 36, color: scheme.onPrimaryContainer),
                    const SizedBox(height: 8),
                    Text('Total Money Saved',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '$sym ${totalSaved.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('by staying under your baseline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Today breakdown
          Text("Today's Breakdown",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _InfoTile(
            icon: Icons.arrow_upward,
            iconColor: scheme.error,
            label: 'Spent Today',
            value: '$sym ${todaySpent.toStringAsFixed(2)}',
          ),
          if (isCoach)
            _InfoTile(
              icon: Icons.arrow_downward,
              iconColor: scheme.primary,
              label: 'Saved Today',
              value: '$sym ${todaySaved.toStringAsFixed(2)}',
            ),
          _InfoTile(
            icon: Icons.monetization_on_outlined,
            iconColor: scheme.tertiary,
            label: 'Cost per Cigarette',
            value: '$sym ${settings.costPerCigarette.toStringAsFixed(2)}',
          ),
          _InfoTile(
            icon: Icons.inventory_2_outlined,
            iconColor: scheme.secondary,
            label: 'Pack Cost',
            value:
                '$sym ${settings.packCost.toStringAsFixed(2)} (${settings.cigarettesPerPack} cigs)',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
