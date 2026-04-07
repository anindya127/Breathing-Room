import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/user_settings.dart';
import '../providers/analytics_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/smoke_provider.dart';
import 'widgets/animated_count.dart';
import 'widgets/icon_grid.dart';
import 'widgets/smoke_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final todayCount = ref.watch(todayCountProvider);
    final todaySpent = ref.watch(todaySpentProvider);
    final sym = currencySymbol(settings.currency);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCoach = settings.mode == TrackingMode.coach;

    // Coach-specific data
    final limit = ref.watch(todayLimitProvider);
    final remaining = ref.watch(remainingProvider);
    final isOver = ref.watch(isOverLimitProvider);
    final isNear = ref.watch(isNearLimitProvider);
    final moneySaved = ref.watch(todayMoneySavedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mode badge + last smoke time
            Chip(
              avatar: Icon(
                isCoach ? Icons.trending_down : Icons.touch_app,
                size: 18,
              ),
              label: Text(settings.mode.label),
            ),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final lastSmoke = ref.watch(lastSmokeTimeProvider).value;
              if (lastSmoke == null) return const SizedBox.shrink();
              return Text(
                'Last smoke: ${DateFormat('h:mm a').format(lastSmoke)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              );
            }),
            const SizedBox(height: 16),

            // Today's count card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Card(
                color: isOver
                    ? scheme.errorContainer
                    : isNear
                        ? scheme.tertiaryContainer
                        : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Today',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isOver
                              ? scheme.onErrorContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedCount(
                        count: todayCount,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOver ? scheme.error : scheme.primary,
                        ),
                      ),
                      if (isCoach) ...[
                        const SizedBox(height: 4),
                        Text(
                          'of $limit allowed',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isOver
                                ? scheme.onErrorContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          todayCount == 1 ? 'cigarette' : 'cigarettes',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coach: Icon Grid
            if (isCoach && limit > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Allowance',
                              style: theme.textTheme.titleSmall),
                          if (remaining > 0)
                            Text('$remaining left',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.bold,
                                ))
                          else
                            Text(
                              isOver
                                  ? '${todayCount - limit} over!'
                                  : 'Limit reached',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      IconGrid(total: limit, smoked: todayCount),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Coach: Warning banners
            if (isCoach && isOver)
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: scheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "You've passed today's limit. Tomorrow is a new day \u2014 don't give up.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (isCoach && isNear && !isOver)
              Card(
                color: scheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: scheme.onTertiaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Almost at your limit. You can do this!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Money row
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: scheme.error, size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent Today',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            )),
                        Text(
                          '$sym ${todaySpent.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isCoach && moneySaved > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Saved Today',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              )),
                          Text(
                            '$sym ${moneySaved.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Per cig',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              )),
                          Text(
                            '$sym ${settings.costPerCigarette.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pack status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2,
                        color: settings.isPackEmpty
                            ? scheme.error
                            : scheme.primary,
                        size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Pack',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            )),
                        Text(
                          settings.isPackEmpty
                              ? 'Empty'
                              : '${settings.packRemaining} left',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: settings.isPackEmpty
                                ? scheme.error
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () => _showAddPackDialog(
                          context, ref, settings, sym),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Pack'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Undo button
            if (todayCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await ref.read(todayEntriesProvider.notifier).undoLast();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Last entry removed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo last'),
                ),
              ),

            // Smoke button with animation
            SmokeButton(
              onPressed: () {
                if (settings.isPackEmpty) {
                  _showAddPackDialog(context, ref, settings, sym,
                      logAfter: true);
                } else {
                  ref.read(todayEntriesProvider.notifier).logSmoke();
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAddPackDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
    String sym, {
    bool logAfter = false,
  }) {
    final costCtrl = TextEditingController(
      text: settings.packCost.toStringAsFixed(2),
    );
    final cigsCtrl = TextEditingController(
      text: settings.cigarettesPerPack.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(logAfter ? 'Pack is empty' : 'Add New Pack'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logAfter)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Your current pack is empty. Add a new one.'),
              ),
            TextField(
              controller: costCtrl,
              decoration: InputDecoration(
                labelText: 'Pack Cost',
                prefixText: '$sym ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cigsCtrl,
              decoration: const InputDecoration(
                labelText: 'Cigarettes in Pack',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final cost = double.tryParse(costCtrl.text) ?? settings.packCost;
              final cigs =
                  int.tryParse(cigsCtrl.text) ?? settings.cigarettesPerPack;

              if (cost <= 0 || cigs <= 0) return;

              // Add pack with new cost and count in one operation
              ref.read(settingsProvider.notifier).addNewPack(
                    packCost: cost,
                    cigarettesPerPack: cigs,
                  );
              Navigator.pop(ctx);

              if (logAfter) {
                // Small delay so settings update before logging
                Future.delayed(const Duration(milliseconds: 100), () {
                  ref.read(todayEntriesProvider.notifier).logSmoke();
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'New pack added ($cigs cigs, $sym${cost.toStringAsFixed(2)})'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(logAfter ? 'Add Pack & Log' : 'Add Pack'),
          ),
        ],
      ),
    );
  }
}
