class UserSettings {
  final double packCost;
  final int cigarettesPerPack;
  final String currency;
  final TrackingMode mode;
  final bool isSetupComplete;

  // Coach Mode fields
  final int dailyBaseline; // starting daily count before reduction
  final int reductionAmount; // how many fewer cigs per step
  final int reductionDays; // step down every N days
  final DateTime? coachStartDate; // when coach mode began
  final AppThemeMode themeMode;

  // Pack tracking
  final int packRemaining; // cigarettes left in current pack
  final int totalPacks; // total packs purchased

  const UserSettings({
    this.packCost = 0.0,
    this.cigarettesPerPack = 20,
    this.currency = 'USD',
    this.mode = TrackingMode.simple,
    this.isSetupComplete = false,
    this.dailyBaseline = 20,
    this.reductionAmount = 1,
    this.reductionDays = 3,
    this.coachStartDate,
    this.themeMode = AppThemeMode.system,
    this.packRemaining = 0,
    this.totalPacks = 0,
  });

  bool get isPackEmpty => packRemaining <= 0;

  double get costPerCigarette =>
      cigarettesPerPack > 0 ? packCost / cigarettesPerPack : 0.0;

  UserSettings copyWith({
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
  }) {
    return UserSettings(
      packCost: packCost ?? this.packCost,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      currency: currency ?? this.currency,
      mode: mode ?? this.mode,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      dailyBaseline: dailyBaseline ?? this.dailyBaseline,
      reductionAmount: reductionAmount ?? this.reductionAmount,
      reductionDays: reductionDays ?? this.reductionDays,
      coachStartDate: coachStartDate ?? this.coachStartDate,
      themeMode: themeMode ?? this.themeMode,
      packRemaining: packRemaining ?? this.packRemaining,
      totalPacks: totalPacks ?? this.totalPacks,
    );
  }
}

enum TrackingMode {
  simple('Simple Counter'),
  coach('Coach Mode');

  final String label;
  const TrackingMode(this.label);
}

enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  final String label;
  const AppThemeMode(this.label);
}

const supportedCurrencies = [
  ('USD', '\$', 'US Dollar'),
  ('EUR', '\u20AC', 'Euro'),
  ('GBP', '\u00A3', 'British Pound'),
  ('JPY', '\u00A5', 'Japanese Yen'),
  ('CNY', '\u00A5', 'Chinese Yuan'),
  ('INR', '\u20B9', 'Indian Rupee'),
  ('CAD', 'C\$', 'Canadian Dollar'),
  ('AUD', 'A\$', 'Australian Dollar'),
  ('BRL', 'R\$', 'Brazilian Real'),
  ('TRY', '\u20BA', 'Turkish Lira'),
];

String currencySymbol(String code) {
  return supportedCurrencies
      .firstWhere((c) => c.$1 == code, orElse: () => (code, code, code))
      .$2;
}
