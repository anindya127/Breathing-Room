import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  UserSettings build() {
    _loadFromPrefs();
    return const UserSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final coachStartMs = prefs.getInt(_keyCoachStart);

    state = UserSettings(
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
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
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
    );
    await _save();
  }
}
