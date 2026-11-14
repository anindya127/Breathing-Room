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


/// The upcoming reduction step, so the app can tell the user what is coming
/// instead of silently tightening the limit.
class CoachStep {
  const CoachStep({
    required this.daysLeft,
    required this.nextLimit,
    required this.isFinal,
  });

  /// Days until the next step-down (0 when the staircase is finished).
  final int daysLeft;

  /// The daily limit that will apply after that step.
  final int nextLimit;

  /// True when this step is the last one (reaches zero) or the limit is already zero.
  final bool isFinal;

  String get label {
    if (nextLimit <= 0 && daysLeft > 0) {
      return 'Next step in $daysLeft ${daysLeft == 1 ? 'day' : 'days'} \u2192 smoke-free';
    }
    if (nextLimit <= 0 && daysLeft == 0) {
      return 'Final step reached \u2014 hold at zero';
    }
    return 'Next step in $daysLeft ${daysLeft == 1 ? 'day' : 'days'} \u2192 $nextLimit a day';
  }
}

/// Pure staircase maths, kept free of Riverpod so it can be unit-tested.
CoachStep? stepFor({
  required int baseline,
  required int amount,
  required int reductionDays,
  required DateTime startDate,
  required DateTime now,
}) {
  if (reductionDays <= 0) return null;
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final today = DateTime(now.year, now.month, now.day);
  final daysElapsed = today.difference(start).inDays;
  if (daysElapsed < 0) return null;

  final stepsDone = daysElapsed ~/ reductionDays;
  final currentLimit = max(0, baseline - stepsDone * amount);
  if (currentLimit <= 0) {
    return const CoachStep(daysLeft: 0, nextLimit: 0, isFinal: true);
  }

  final daysLeft = (stepsDone + 1) * reductionDays - daysElapsed;
  final nextLimit = max(0, baseline - (stepsDone + 1) * amount);
  return CoachStep(
    daysLeft: daysLeft,
    nextLimit: nextLimit,
    isFinal: nextLimit <= 0,
  );
}

final nextStepProvider = Provider<CoachStep?>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.mode != TrackingMode.coach) return null;
  final start = settings.coachStartDate;
  if (start == null) return null;
  return stepFor(
    baseline: settings.dailyBaseline,
    amount: settings.reductionAmount,
    reductionDays: settings.reductionDays,
    startDate: start,
    now: DateTime.now(),
  );
});


/// One phase of the staircase plan.
class PlanPhase {
  const PlanPhase({
    required this.index,
    required this.fromDay,
    required this.toDay,
    required this.limit,
  });

  final int index;
  final int fromDay;
  final int toDay;
  final int limit;

  bool get isFinal => limit <= 0;

  String get dayLabel {
    final first = fromDay + 1;
    final last = toDay + 1;
    return first == last ? 'Day $first' : 'Days $first\u2013$last';
  }
}

/// The whole staircase, so the user can see what is coming instead of
/// discovering a lower limit by surprise.
List<PlanPhase> planFor({
  required int baseline,
  required int amount,
  required int reductionDays,
  int maxPhases = 52,
}) {
  if (reductionDays <= 0 || amount <= 0 || baseline <= 0) return const [];
  final phases = <PlanPhase>[];
  for (var i = 0; i < maxPhases; i++) {
    final limit = baseline - i * amount;
    final clamped = limit < 0 ? 0 : limit;
    phases.add(PlanPhase(
      index: i,
      fromDay: i * reductionDays,
      toDay: (i + 1) * reductionDays - 1,
      limit: clamped,
    ));
    if (clamped <= 0) break;
  }
  return phases;
}

/// Which phase the user is on right now.
int currentPhaseIndex({
  required int reductionDays,
  required DateTime startDate,
  required DateTime now,
}) {
  if (reductionDays <= 0) return 0;
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(start).inDays;
  if (days < 0) return 0;
  return days ~/ reductionDays;
}

final planProvider = Provider<List<PlanPhase>>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.mode != TrackingMode.coach) return const [];
  return planFor(
    baseline: settings.dailyBaseline,
    amount: settings.reductionAmount,
    reductionDays: settings.reductionDays,
  );
});
