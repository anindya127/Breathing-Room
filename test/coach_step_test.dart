import 'package:flutter_test/flutter_test.dart';
import 'package:smoke_counter/providers/coach_provider.dart';

void main() {
  final start = DateTime(2026, 1, 1);

  CoachStep? step(int dayOffset, {int baseline = 10, int amount = 1, int days = 7}) =>
      stepFor(
        baseline: baseline,
        amount: amount,
        reductionDays: days,
        startDate: start,
        now: start.add(Duration(days: dayOffset)),
      );

  group('staircase step countdown', () {
    test('day 0 starts one full step away', () {
      final s = step(0)!;
      expect(s.daysLeft, 7);
      expect(s.nextLimit, 9);
      expect(s.isFinal, isFalse);
    });

    test('mid-step reports the days remaining in that step', () {
      final s = step(3)!;
      expect(s.daysLeft, 4);
      expect(s.nextLimit, 9);
    });

    test('the day a step completes, the next one begins', () {
      final s = step(7)!;
      expect(s.daysLeft, 7);
      expect(s.nextLimit, 8);
    });

    test('a step that reaches zero is flagged final', () {
      final s = step(7, baseline: 10, amount: 5)!;
      expect(s.nextLimit, 0);
      expect(s.isFinal, isTrue);
      expect(s.daysLeft, 7);
      expect(s.label, contains('smoke-free'));
    });

    test('once at zero the staircase reports no further step', () {
      final s = step(30, baseline: 10, amount: 5)!;
      expect(s.nextLimit, 0);
      expect(s.isFinal, isTrue);
      expect(s.daysLeft, 0);
      expect(s.label, contains('hold at zero'));
    });

    test('a single remaining day is not pluralised', () {
      final s = step(6)!;
      expect(s.daysLeft, 1);
      expect(s.label, contains('1 day '));
    });

    test('zero reduction window means no steps at all', () {
      expect(step(5, days: 0), isNull);
    });

    test('a start date in the future produces no step', () {
      final s = stepFor(
        baseline: 10,
        amount: 1,
        reductionDays: 7,
        startDate: start,
        now: start.subtract(const Duration(days: 2)),
      );
      expect(s, isNull);
    });
  });

  group('staircase plan', () {
    test('phases cover every day and stop at zero', () {
      final phases = planFor(baseline: 10, amount: 3, reductionDays: 7);
      expect(phases.length, 5); // 10, 7, 4, 1, 0
      expect(phases.first.limit, 10);
      expect(phases.first.dayLabel, 'Days 1\u20137');
      expect(phases.last.limit, 0);
      expect(phases.last.isFinal, isTrue);
      expect(phases[3].limit, 1);
      expect(phases.last.dayLabel, 'Days 29\u201335');
    });

    test('a single-phase plan is labelled in the singular', () {
      final phases = planFor(baseline: 10, amount: 20, reductionDays: 1);
      expect(phases.first.dayLabel, 'Day 1');
      expect(phases.first.limit, 10);
      expect(phases.last.limit, 0);
    });

    test('invalid inputs produce no plan', () {
      expect(planFor(baseline: 10, amount: 0, reductionDays: 7), isEmpty);
      expect(planFor(baseline: 10, amount: 1, reductionDays: 0), isEmpty);
      expect(planFor(baseline: 0, amount: 1, reductionDays: 7), isEmpty);
    });

    test('the current phase advances by whole steps', () {
      expect(currentPhaseIndex(reductionDays: 7, startDate: start, now: start), 0);
      expect(
        currentPhaseIndex(
          reductionDays: 7,
          startDate: start,
          now: start.add(const Duration(days: 6)),
        ),
        0,
      );
      expect(
        currentPhaseIndex(
          reductionDays: 7,
          startDate: start,
          now: start.add(const Duration(days: 7)),
        ),
        1,
      );
    });
  });
}
