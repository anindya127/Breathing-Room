import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import 'settings_provider.dart';
import 'smoke_provider.dart';

/// Today's daily limit calculated by the Staircase algorithm.
///
/// Formula:
///   daysElapsed = today - coachStartDate
///   stepsCompleted = daysElapsed ÷ reductionDays  (integer division)
///   todayLimit = baseline - (stepsCompleted × reductionAmount)
///   minimum limit = 0
final todayLimitProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.mode != TrackingMode.coach) return -1; // unlimited

  final startDate = settings.coachStartDate;
  if (startDate == null) return settings.dailyBaseline;

  final now = DateTime.now();
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final today = DateTime(now.year, now.month, now.day);
  final daysElapsed = today.difference(start).inDays;

  final steps = settings.reductionDays > 0
      ? daysElapsed ~/ settings.reductionDays
      : 0;
  final limit =
      settings.dailyBaseline - (steps * settings.reductionAmount);

  return max(0, limit);
});

/// How many cigarettes the user has left today (coach mode).
final remainingProvider = Provider<int>((ref) {
  final limit = ref.watch(todayLimitProvider);
  if (limit < 0) return -1; // simple mode, unlimited
  final smoked = ref.watch(todayCountProvider);
  return max(0, limit - smoked);
});

/// Whether the user is over their daily limit.
final isOverLimitProvider = Provider<bool>((ref) {
  final limit = ref.watch(todayLimitProvider);
  if (limit < 0) return false;
  final smoked = ref.watch(todayCountProvider);
  return smoked > limit;
});

/// Whether the user is close to their limit (80%+).
final isNearLimitProvider = Provider<bool>((ref) {
  final limit = ref.watch(todayLimitProvider);
  if (limit <= 0) return false;
  final smoked = ref.watch(todayCountProvider);
  return smoked >= (limit * 0.8) && smoked <= limit;
});

/// Money saved today: (baseline - smoked) × costPerCig.
/// Only meaningful in coach mode and only if user smoked less than baseline.
final todayMoneySavedProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.mode != TrackingMode.coach) return 0.0;

  final smoked = ref.watch(todayCountProvider);
  final avoided = settings.dailyBaseline - smoked;
  if (avoided <= 0) return 0.0;

  return avoided * settings.costPerCigarette;
});
