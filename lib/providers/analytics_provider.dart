import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/smoke_entry.dart';
import '../services/database_service.dart';
import 'settings_provider.dart';
import 'smoke_provider.dart';

/// Entries for the current week (Monday–Sunday).
final weeklyEntriesProvider =
    FutureProvider<List<SmokeEntry>>((ref) async {
  // Depend on today's entries so we refresh when a smoke is logged.
  ref.watch(todayEntriesProvider);

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final nextMonday = monday.add(const Duration(days: 7));
  return DatabaseService.getEntriesInRange(monday, nextMonday);
});

/// Daily counts for the current week: index 0 = Monday, 6 = Sunday.
final weeklyCountsProvider = Provider<List<int>>((ref) {
  final entries = ref.watch(weeklyEntriesProvider).value ?? [];
  final counts = List.filled(7, 0);

  for (final e in entries) {
    final dayIndex = e.timestamp.weekday - 1; // Mon=0 .. Sun=6
    counts[dayIndex]++;
  }
  return counts;
});

/// Entries for the last 30 days.
final monthlyEntriesProvider =
    FutureProvider<List<SmokeEntry>>((ref) async {
  ref.watch(todayEntriesProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thirtyDaysAgo = today.subtract(const Duration(days: 29));
  final tomorrow = today.add(const Duration(days: 1));
  return DatabaseService.getEntriesInRange(thirtyDaysAgo, tomorrow);
});

/// Daily counts for the last 30 days: index 0 = 29 days ago, index 29 = today.
final monthlyCountsProvider = Provider<List<int>>((ref) {
  final entries = ref.watch(monthlyEntriesProvider).value ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final counts = List.filled(30, 0);

  for (final e in entries) {
    final entryDay = DateTime(
        e.timestamp.year, e.timestamp.month, e.timestamp.day);
    final daysAgo = today.difference(entryDay).inDays;
    if (daysAgo >= 0 && daysAgo < 30) {
      counts[29 - daysAgo]++;
    }
  }
  return counts;
});

/// Today's entries grouped by hour for the daily timeline view.
final todayHourlyProvider = Provider<Map<int, int>>((ref) {
  final entries = ref.watch(todayEntriesProvider).value ?? [];
  final hourly = <int, int>{};
  for (final e in entries) {
    final hour = e.timestamp.hour;
    hourly[hour] = (hourly[hour] ?? 0) + 1;
  }
  return hourly;
});

/// All-time total money spent.
final totalSpentProvider = FutureProvider<double>((ref) async {
  ref.watch(todayEntriesProvider);

  final now = DateTime.now();
  final farPast = DateTime(2020);
  final tomorrow =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final entries = await DatabaseService.getEntriesInRange(farPast, tomorrow);
  double total = 0.0;
  for (final e in entries) {
    total += e.cost;
  }
  return total;
});

/// All-time total money saved (coach mode: baseline × days - actual smoked × costPerCig).
final totalSavedProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.coachStartDate == null) return 0.0;

  final now = DateTime.now();
  final start = settings.coachStartDate!;
  final daysOnCoach = DateTime(now.year, now.month, now.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays +
      1;

  final totalSpent = ref.watch(totalSpentProvider).value ?? 0.0;
  final baselineSpend =
      daysOnCoach * settings.dailyBaseline * settings.costPerCigarette;

  final saved = baselineSpend - totalSpent;
  return saved > 0 ? saved : 0.0;
});

/// All-time total cigarettes smoked.
final totalSmokesProvider = FutureProvider<int>((ref) async {
  ref.watch(todayEntriesProvider);

  final now = DateTime.now();
  final farPast = DateTime(2020);
  final tomorrow =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final entries = await DatabaseService.getEntriesInRange(farPast, tomorrow);
  return entries.length;
});
