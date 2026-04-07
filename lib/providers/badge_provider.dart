import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'settings_provider.dart';
import 'smoke_provider.dart';

/// Computes which badges are earned. Returns a set of badge IDs.
final earnedBadgesProvider = FutureProvider<Set<String>>((ref) async {
  // Re-evaluate when today's entries change.
  final todayAsync = ref.watch(todayEntriesProvider);
  // Wait for today's entries to be loaded before querying.
  if (todayAsync is AsyncLoading) return {};

  final settings = ref.watch(settingsProvider);
  final earned = <String>{};

  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final farPast = DateTime(2020);
    final tomorrow = today.add(const Duration(days: 1));

    final allEntries =
        await DatabaseService.getEntriesInRange(farPast, tomorrow);

    if (allEntries.isEmpty) return earned;

    // ── first_log ──
    earned.add('first_log');

    // ── Build daily counts map ──
    final dailyCounts = <DateTime, int>{};
    for (final e in allEntries) {
      final day =
          DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
    }

    // ── Days tracking ──
    final firstDay =
        dailyCounts.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final daysTracking = today.difference(firstDay).inDays + 1;

    if (daysTracking >= 7) earned.add('week_1');
    if (daysTracking >= 30) earned.add('month_1');

    // ── Coach mode calculations ──
    final baseline = settings.dailyBaseline;
    final costPerCig = settings.costPerCigarette;
    final coachStart = settings.coachStartDate;

    if (coachStart != null && baseline > 0) {
      final startDay =
          DateTime(coachStart.year, coachStart.month, coachStart.day);

      // Under-budget streak (consecutive COMPLETED days under limit)
      // Exclude today — the day isn't over yet.
      int currentStreak = 0;
      int maxStreak = 0;
      final totalDays = today.difference(startDay).inDays;

      for (int d = 0; d < totalDays; d++) {
        final day = startDay.add(Duration(days: d));
        final count = dailyCounts[day] ?? 0;

        // Calculate limit for that day
        final daysElapsed = day.difference(startDay).inDays;
        final steps = settings.reductionDays > 0
            ? daysElapsed ~/ settings.reductionDays
            : 0;
        final limit = baseline - (steps * settings.reductionAmount);
        final effectiveLimit = limit > 0 ? limit : 0;

        if (count <= effectiveLimit) {
          currentStreak++;
          if (currentStreak > maxStreak) maxStreak = currentStreak;
        } else {
          currentStreak = 0;
        }
      }

      if (maxStreak >= 1) earned.add('under_budget_1');
      if (maxStreak >= 3) earned.add('streak_3');
      if (maxStreak >= 7) earned.add('streak_7');
      if (maxStreak >= 14) earned.add('streak_14');
      if (maxStreak >= 30) earned.add('streak_30');

      // Only count completed days (exclude today)
      final completedDays = daysTracking - 1;

      if (completedDays > 0) {
        // Count smokes from completed days only
        final todaySmokes = dailyCounts[today] ?? 0;
        final completedSmokes = allEntries.length - todaySmokes;
        double completedSpent = 0;
        for (final e in allEntries) {
          final eDay = DateTime(
              e.timestamp.year, e.timestamp.month, e.timestamp.day);
          if (eDay != today) completedSpent += e.cost;
        }

        // Total smokes avoided (baseline × completed days - actual)
        final totalBaseline = completedDays * baseline;
        final avoided = totalBaseline - completedSmokes;

        if (avoided >= 100) earned.add('avoided_100');
        if (avoided >= 500) earned.add('avoided_500');

        // Total money saved
        final baselineSpend = totalBaseline * costPerCig;
        final saved = baselineSpend - completedSpent;

        if (saved >= 10) earned.add('saved_10');
        if (saved >= 50) earned.add('saved_50');
        if (saved >= 100) earned.add('saved_100');
        if (saved >= 500) earned.add('saved_500');

        // Daily average vs baseline (completed days only)
        final avg = completedSmokes / completedDays;
        if (avg <= baseline / 2) earned.add('half_baseline');
        if (avg <= baseline / 4) earned.add('quarter_baseline');
      }
    }

    // ── Zero day (a COMPLETED day with 0 smokes — exclude today) ──
    for (int d = 0; d < today.difference(firstDay).inDays; d++) {
      final day = firstDay.add(Duration(days: d));
      if (!dailyCounts.containsKey(day) || dailyCounts[day] == 0) {
        earned.add('zero_day');
        break;
      }
    }

    return earned;
  } catch (e) {
    // If DB isn't ready yet, return empty
    return earned;
  }
});

/// Number of earned badges for display.
final earnedBadgeCountProvider = Provider<int>((ref) {
  return ref.watch(earnedBadgesProvider).value?.length ?? 0;
});
