import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../providers/badge_provider.dart';

class TrophyScreen extends ConsumerWidget {
  const TrophyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnedAsync = ref.watch(earnedBadgesProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Trophy Room')),
      body: earnedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (earnedIds) {
          final earnedCount = earnedIds.length;
          final totalCount = allBadges.length;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: totalCount > 0
                                  ? earnedCount / totalCount
                                  : 0,
                              strokeWidth: 8,
                              backgroundColor:
                                  scheme.surfaceContainerHighest,
                              color: scheme.primary,
                            ),
                            Text(
                              '$earnedCount/$totalCount',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Badges Earned',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),

              // Badge categories
              for (final category in BadgeCategory.values) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      category.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final badges = allBadges
                            .where((b) => b.category == category)
                            .toList();
                        if (index >= badges.length) return null;
                        final badge = badges[index];
                        final isEarned = earnedIds.contains(badge.id);
                        return _BadgeTile(
                          badge: badge,
                          isEarned: isEarned,
                          onTap: () => _showBadgeDetail(
                              context, badge, isEarned, theme),
                        );
                      },
                      childCount: allBadges
                          .where((b) => b.category == category)
                          .length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  void _showBadgeDetail(
      BuildContext context, AppBadge badge, bool isEarned, ThemeData theme) {
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badge.icon,
                size: 56,
                color: isEarned ? badge.color : scheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                badge.title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(
                  isEarned ? Icons.check_circle : Icons.lock,
                  size: 18,
                  color: isEarned ? scheme.primary : scheme.outline,
                ),
                label: Text(isEarned ? 'Earned!' : 'Locked'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AppBadge badge;
  final bool isEarned;
  final VoidCallback onTap;

  const _BadgeTile({
    required this.badge,
    required this.isEarned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: isEarned ? null : scheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                badge.icon,
                size: 32,
                color: isEarned ? badge.color : scheme.outlineVariant,
              ),
              const SizedBox(height: 6),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? null : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
