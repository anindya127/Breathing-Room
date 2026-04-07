import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/smoke_entry.dart';
import '../services/database_service.dart';
import 'settings_provider.dart';

/// Holds today's smoke entries, refreshed from the database.
final todayEntriesProvider =
    AsyncNotifierProvider<TodayEntriesNotifier, List<SmokeEntry>>(
  TodayEntriesNotifier.new,
);

class TodayEntriesNotifier extends AsyncNotifier<List<SmokeEntry>> {
  @override
  Future<List<SmokeEntry>> build() async {
    return DatabaseService.getEntriesForDay(DateTime.now());
  }

  Future<void> logSmoke() async {
    final settings = ref.read(settingsProvider);
    final entry = SmokeEntry(
      timestamp: DateTime.now(),
      cost: settings.costPerCigarette,
    );
    await DatabaseService.insertEntry(entry);
    state = AsyncData(await DatabaseService.getEntriesForDay(DateTime.now()));
  }

  Future<void> undoLast() async {
    final entries = state.value;
    if (entries == null || entries.isEmpty) return;
    await DatabaseService.deleteEntry(entries.first.id!);
    state = AsyncData(await DatabaseService.getEntriesForDay(DateTime.now()));
  }

  Future<void> refresh() async {
    state = AsyncData(await DatabaseService.getEntriesForDay(DateTime.now()));
  }
}

/// Derived providers for quick access.

final todayCountProvider = Provider<int>((ref) {
  return ref.watch(todayEntriesProvider).value?.length ?? 0;
});

final todaySpentProvider = Provider<double>((ref) {
  final entries = ref.watch(todayEntriesProvider).value ?? [];
  return entries.fold(0.0, (sum, e) => sum + e.cost);
});
