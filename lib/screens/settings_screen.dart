import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _packCostCtrl;
  late TextEditingController _cigsCtrl;
  late TextEditingController _baselineCtrl;
  late String _currency;
  late TrackingMode _mode;
  late int _reductionAmount;
  late int _reductionDays;
  late AppThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _packCostCtrl = TextEditingController(text: s.packCost.toStringAsFixed(2));
    _cigsCtrl = TextEditingController(text: s.cigarettesPerPack.toString());
    _baselineCtrl = TextEditingController(text: s.dailyBaseline.toString());
    _currency = s.currency;
    _mode = s.mode;
    _reductionAmount = s.reductionAmount;
    _reductionDays = s.reductionDays;
    _themeMode = s.themeMode;
  }

  @override
  void dispose() {
    _packCostCtrl.dispose();
    _cigsCtrl.dispose();
    _baselineCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cost = double.tryParse(_packCostCtrl.text) ?? 0;
    final cigs = int.tryParse(_cigsCtrl.text) ?? 20;

    if (cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pack cost')),
      );
      return;
    }

    final baseline = int.tryParse(_baselineCtrl.text) ?? 20;
    final currentSettings = ref.read(settingsProvider);

    // If switching to coach mode for the first time, set the start date
    DateTime? coachStart = currentSettings.coachStartDate;
    if (_mode == TrackingMode.coach && coachStart == null) {
      coachStart = DateTime.now();
    }

    await ref.read(settingsProvider.notifier).updateSettings(
          packCost: cost,
          cigarettesPerPack: cigs,
          currency: _currency,
          mode: _mode,
          dailyBaseline: baseline,
          reductionAmount: _reductionAmount,
          reductionDays: _reductionDays,
          coachStartDate: coachStart,
          themeMode: _themeMode,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme
          Text('Theme',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: AppThemeMode.values.map((m) {
              return ButtonSegment(
                value: m,
                label: Text(m.label),
                icon: Icon(switch (m) {
                  AppThemeMode.system => Icons.brightness_auto,
                  AppThemeMode.light => Icons.light_mode,
                  AppThemeMode.dark => Icons.dark_mode,
                }),
              );
            }).toList(),
            selected: {_themeMode},
            onSelectionChanged: (v) => setState(() => _themeMode = v.first),
          ),
          const SizedBox(height: 28),

          // Mode selection
          Text('Tracking Mode',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<TrackingMode>(
            segments: TrackingMode.values.map((m) {
              return ButtonSegment(value: m, label: Text(m.label));
            }).toList(),
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
          const SizedBox(height: 28),

          // Currency
          Text('Currency',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: supportedCurrencies.map((c) {
              return DropdownMenuItem(
                value: c.$1,
                child: Text('${c.$2}  ${c.$3}'),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _currency = v);
            },
          ),
          const SizedBox(height: 20),

          // Pack cost
          TextFormField(
            controller: _packCostCtrl,
            decoration: InputDecoration(
              labelText: 'Pack Cost',
              prefixText: '${currencySymbol(_currency)} ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 20),

          // Cigs per pack
          TextFormField(
            controller: _cigsCtrl,
            decoration: const InputDecoration(
              labelText: 'Cigarettes per Pack',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          // Coach Mode settings
          if (_mode == TrackingMode.coach) ...[
            const SizedBox(height: 32),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 20),
            Text('Coach Settings',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _baselineCtrl,
              decoration: const InputDecoration(
                labelText: 'Daily Baseline',
                helperText: 'Your starting daily count',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            Text('Reduce by', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 cig')),
                ButtonSegment(value: 2, label: Text('2 cigs')),
                ButtonSegment(value: 3, label: Text('3 cigs')),
              ],
              selected: {_reductionAmount},
              onSelectionChanged: (v) =>
                  setState(() => _reductionAmount = v.first),
            ),
            const SizedBox(height: 16),

            Text('Every', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2 days')),
                ButtonSegment(value: 3, label: Text('3 days')),
                ButtonSegment(value: 5, label: Text('5 days')),
                ButtonSegment(value: 7, label: Text('7 days')),
              ],
              selected: {_reductionDays},
              onSelectionChanged: (v) =>
                  setState(() => _reductionDays = v.first),
            ),
          ],

          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
