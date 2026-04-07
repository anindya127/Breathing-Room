import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/user_settings.dart';
import '../providers/analytics_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/smoke_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyView(theme: theme),
          _WeeklyView(theme: theme),
          _MonthlyView(theme: theme),
        ],
      ),
    );
  }
}

/// Daily view: shows what hours you smoked today.
class _DailyView extends ConsumerWidget {
  final ThemeData theme;
  const _DailyView({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourly = ref.watch(todayHourlyProvider);
    final scheme = theme.colorScheme;

    if (hourly.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smoke_free, size: 48, color: scheme.outlineVariant),
            const SizedBox(height: 12),
            Text('No smokes logged today',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final maxCount =
        hourly.values.fold(0, (a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('When you smoked today',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Builder(builder: (context) {
                final spent = ref.watch(todaySpentProvider);
                final sym = currencySymbol(
                    ref.watch(settingsProvider).currency);
                return Text('$sym${spent.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.error,
                    ));
              }),
            ],
          ),
          const SizedBox(height: 4),
          Text('Identify your trigger times',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount + 1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hour = group.x;
                      final label = _formatHour(hour);
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()} smokes',
                        TextStyle(color: scheme.onPrimary, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        if (value == value.toInt().toDouble()) {
                          return Text('${value.toInt()}',
                              style: const TextStyle(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatHour(value.toInt()),
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (hour) {
                  final count = hourly[hour] ?? 0;
                  return BarChartGroupData(
                    x: hour,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: count > 0 ? scheme.primary : scheme.surfaceContainerHighest,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12a';
    if (hour < 12) return '${hour}a';
    if (hour == 12) return '12p';
    return '${hour - 12}p';
  }
}

/// Weekly view: bar chart Mon–Sun.
class _WeeklyView extends ConsumerWidget {
  final ThemeData theme;
  const _WeeklyView({required this.theme});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(weeklyCountsProvider);
    final weeklySpent = ref.watch(weeklySpentProvider);
    final sym = currencySymbol(ref.watch(settingsProvider).currency);
    final scheme = theme.colorScheme;
    final maxY =
        counts.fold(0, (a, b) => a > b ? a : b).toDouble();
    final totalWeekSpent = weeklySpent.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('$sym${totalWeekSpent.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.error,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${counts.fold(0, (a, b) => a + b)} cigarettes',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY + 2 : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_days[group.x]}\n${rod.toY.toInt()}',
                        TextStyle(color: scheme.onPrimary, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, _) {
                        if (value == value.toInt().toDouble()) {
                          return Text('${value.toInt()}',
                              style: const TextStyle(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        final isToday = DateTime.now().weekday - 1 == i;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _days[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday ? scheme.primary : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval:
                      maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: counts[i].toDouble(),
                        color: DateTime.now().weekday - 1 == i
                            ? scheme.primary
                            : scheme.primaryContainer,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Monthly view: line/bar chart for last 30 days.
class _MonthlyView extends ConsumerWidget {
  final ThemeData theme;
  const _MonthlyView({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(monthlyCountsProvider);
    final monthlySpent = ref.watch(monthlySpentProvider);
    final sym = currencySymbol(ref.watch(settingsProvider).currency);
    final scheme = theme.colorScheme;
    final maxY =
        counts.fold(0, (a, b) => a > b ? a : b).toDouble();
    final total = counts.fold(0, (a, b) => a + b);
    final totalMonthSpent = monthlySpent.fold(0.0, (a, b) => a + b);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last 30 Days',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('$sym${totalMonthSpent.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.error,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total: $total cigarettes  |  Avg: ${total > 0 ? (total / 30).toStringAsFixed(1) : "0"}/day',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                maxY: maxY > 0 ? maxY + 2 : 10,
                minY: 0,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final date = today
                            .subtract(Duration(days: 29 - spot.x.toInt()));
                        final label = DateFormat('MMM d').format(date);
                        return LineTooltipItem(
                          '$label\n${spot.y.toInt()} smokes',
                          TextStyle(color: scheme.onPrimary, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, _) {
                        if (value == value.toInt().toDouble()) {
                          return Text('${value.toInt()}',
                              style: const TextStyle(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= 30) return const SizedBox.shrink();
                        final date =
                            today.subtract(Duration(days: 29 - i));
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('d/M').format(date),
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval:
                      maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(30, (i) {
                      return FlSpot(i.toDouble(), counts[i].toDouble());
                    }),
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: scheme.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withAlpha(40),
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
}
