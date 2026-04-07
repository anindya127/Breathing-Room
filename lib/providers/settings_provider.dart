import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/user_settings.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<UserSettings> {
  static const _keyPackCost = 'pack_cost';
  static const _keyCigsPerPack = 'cigs_per_pack';
  static const _keyCurrency = 'currency';
  static const _keyMode = 'mode';
  static const _keySetupComplete = 'setup_complete';
  static const _keyBaseline = 'daily_baseline';
  static const _keyReductionAmount = 'reduction_amount';
  static const _keyReductionDays = 'reduction_days';
  static const _keyCoachStart = 'coach_start_date';
  static const _keyThemeMode = 'theme_mode';
  static const _keyPackRemaining = 'pack_remaining';
  static const _keyTotalPacks = 'total_packs';

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  UserSettings build() {
    // Synchronous load — prefs are pre-loaded in main()
    final prefs = _prefs;
    final coachStartMs = prefs.getInt(_keyCoachStart);

    return UserSettings(
      packCost: prefs.getDouble(_keyPackCost) ?? 0.0,
      cigarettesPerPack: prefs.getInt(_keyCigsPerPack) ?? 20,
      currency: prefs.getString(_keyCurrency) ?? 'USD',
      mode: TrackingMode.values.byName(
        prefs.getString(_keyMode) ?? 'simple',
      ),
      isSetupComplete: prefs.getBool(_keySetupComplete) ?? false,
      dailyBaseline: prefs.getInt(_keyBaseline) ?? 20,
      reductionAmount: prefs.getInt(_keyReductionAmount) ?? 1,
      reductionDays: prefs.getInt(_keyReductionDays) ?? 3,
      coachStartDate: coachStartMs != null
          ? DateTime.fromMillisecondsSinceEpoch(coachStartMs)
          : null,
      themeMode: AppThemeMode.values.byName(
        prefs.getString(_keyThemeMode) ?? 'system',
      ),
      packRemaining: prefs.getInt(_keyPackRemaining) ?? 0,
      totalPacks: prefs.getInt(_keyTotalPacks) ?? 0,
    );
  }

  Future<void> _save() async {
    final prefs = _prefs;
    await prefs.setDouble(_keyPackCost, state.packCost);
    await prefs.setInt(_keyCigsPerPack, state.cigarettesPerPack);
    await prefs.setString(_keyCurrency, state.currency);
    await prefs.setString(_keyMode, state.mode.name);
    await prefs.setBool(_keySetupComplete, state.isSetupComplete);
    await prefs.setInt(_keyBaseline, state.dailyBaseline);
    await prefs.setInt(_keyReductionAmount, state.reductionAmount);
    await prefs.setInt(_keyReductionDays, state.reductionDays);
    if (state.coachStartDate != null) {
      await prefs.setInt(
          _keyCoachStart, state.coachStartDate!.millisecondsSinceEpoch);
    }
    await prefs.setString(_keyThemeMode, state.themeMode.name);
    await prefs.setInt(_keyPackRemaining, state.packRemaining);
    await prefs.setInt(_keyTotalPacks, state.totalPacks);
  }

  Future<void> updateSettings({
    double? packCost,
    int? cigarettesPerPack,
    String? currency,
    TrackingMode? mode,
    bool? isSetupComplete,
    int? dailyBaseline,
    int? reductionAmount,
    int? reductionDays,
    DateTime? coachStartDate,
    AppThemeMode? themeMode,
    int? packRemaining,
    int? totalPacks,
  }) async {
    state = state.copyWith(
      packCost: packCost,
      cigarettesPerPack: cigarettesPerPack,
      currency: currency,
      mode: mode,
      isSetupComplete: isSetupComplete,
      dailyBaseline: dailyBaseline,
      reductionAmount: reductionAmount,
      reductionDays: reductionDays,
      coachStartDate: coachStartDate,
      themeMode: themeMode,
      packRemaining: packRemaining,
      totalPacks: totalPacks,
    );
    await _save();
  }

  Future<void> completeSetup({
    required double packCost,
    required int cigarettesPerPack,
    required String currency,
    required TrackingMode mode,
    int dailyBaseline = 20,
    int reductionAmount = 1,
    int reductionDays = 3,
  }) async {
    state = UserSettings(
      packCost: packCost,
      cigarettesPerPack: cigarettesPerPack,
      currency: currency,
      mode: mode,
      isSetupComplete: true,
      dailyBaseline: dailyBaseline,
      reductionAmount: reductionAmount,
      reductionDays: reductionDays,
      coachStartDate: mode == TrackingMode.coach ? DateTime.now() : null,
      packRemaining: cigarettesPerPack, // First pack starts full
      totalPacks: 1,
    );
    await _save();
  }

  /// Use one cigarette from the current pack.
  Future<void> useOneCigarette() async {
    final remaining = state.packRemaining;
    if (remaining > 0) {
      state = state.copyWith(packRemaining: remaining - 1);
      await _save();
    }
  }

  /// Restore one cigarette to the pack (on undo).
  Future<void> restoreOneCigarette() async {
    state = state.copyWith(packRemaining: state.packRemaining + 1);
    await _save();
  }

  /// Add a new pack.
  Future<void> addNewPack() async {
    state = state.copyWith(
      packRemaining: state.packRemaining + state.cigarettesPerPack,
      totalPacks: state.totalPacks + 1,
    );
    await _save();
  }
}
