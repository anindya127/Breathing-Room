import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_settings.dart';
import '../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form values
  TrackingMode _selectedMode = TrackingMode.simple;
  String _selectedCurrency = 'USD';
  final _packCostController = TextEditingController();
  final _cigsPerPackController = TextEditingController(text: '20');

  // Coach fields
  final _baselineController = TextEditingController(text: '20');
  int _reductionAmount = 1;
  int _reductionDays = 3;

  int get _totalPages => _selectedMode == TrackingMode.coach ? 4 : 3;
  bool get _isLastPage => _currentPage == _totalPages - 1;

  @override
  void dispose() {
    _pageController.dispose();
    _packCostController.dispose();
    _cigsPerPackController.dispose();
    _baselineController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishSetup() async {
    final packCost = double.tryParse(_packCostController.text) ?? 0.0;
    final cigsPerPack = int.tryParse(_cigsPerPackController.text) ?? 20;

    if (packCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pack cost')),
      );
      return;
    }

    final baseline = int.tryParse(_baselineController.text) ?? 20;

    await ref.read(settingsProvider.notifier).completeSetup(
          packCost: packCost,
          cigarettesPerPack: cigsPerPack,
          currency: _selectedCurrency,
          mode: _selectedMode,
          dailyBaseline: baseline,
          reductionAmount: _reductionAmount,
          reductionDays: _reductionDays,
        );

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = <Widget>[
      _buildWelcomePage(theme),
      _buildModePage(theme),
      _buildCostPage(theme),
      if (_selectedMode == TrackingMode.coach) _buildCoachSetupPage(theme),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return Container(
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (!_isLastPage)
                    FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(120, 48),
                      ),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _finishSetup,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(180, 48),
                      ),
                      child: const Text('Start My Journey'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.air, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Breathing Room',
            style: theme.textTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal companion on the path to a smoke-free life. '
            'No judgement, just support.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildModePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Path',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _ModeCard(
            title: 'Simple Counter',
            description:
                'Just count your daily smokes. No rules, no pressure.',
            icon: Icons.touch_app,
            isSelected: _selectedMode == TrackingMode.simple,
            onTap: () => setState(() => _selectedMode = TrackingMode.simple),
          ),
          const SizedBox(height: 16),
          _ModeCard(
            title: 'Coach Mode',
            description:
                'The app gradually reduces your daily limit over time — like stepping down a staircase.',
            icon: Icons.trending_down,
            isSelected: _selectedMode == TrackingMode.coach,
            onTap: () => setState(() => _selectedMode = TrackingMode.coach),
          ),
        ],
      ),
    );
  }

  Widget _buildCostPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Text(
            'Pack Details',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us track how much you spend and save.',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: supportedCurrencies.map((c) {
              return DropdownMenuItem(
                value: c.$1,
                child: Text('${c.$2}  ${c.$3} (${c.$1})'),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedCurrency = v);
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _packCostController,
            decoration: InputDecoration(
              labelText: 'Pack Cost',
              prefixText: '${currencySymbol(_selectedCurrency)} ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _cigsPerPackController,
            decoration: const InputDecoration(
              labelText: 'Cigarettes per Pack',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_costPreview,
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.trending_down, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Set Up Your Staircase',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll gradually reduce your daily limit. Start with where you are now — no shame.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Daily baseline
          TextFormField(
            controller: _baselineController,
            decoration: const InputDecoration(
              labelText: 'How many do you smoke per day?',
              helperText: 'Your current daily average',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),

          // Reduction amount
          Text('Reduce by', style: theme.textTheme.titleMedium),
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
          const SizedBox(height: 24),

          // Reduction interval
          Text('Every', style: theme.textTheme.titleMedium),
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
          const SizedBox(height: 24),

          // Preview
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.stacked_line_chart,
                      color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _staircasePreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _costPreview {
    final cost = double.tryParse(_packCostController.text) ?? 0;
    final cigs = int.tryParse(_cigsPerPackController.text) ?? 20;
    if (cost <= 0 || cigs <= 0) return 'Enter your pack details above';
    final perCig = (cost / cigs).toStringAsFixed(2);
    final sym = currencySymbol(_selectedCurrency);
    return 'Each cigarette costs you $sym$perCig';
  }

  String get _staircasePreview {
    final baseline = int.tryParse(_baselineController.text) ?? 20;
    final afterOneStep = baseline - _reductionAmount;
    final daysToZero = _reductionDays > 0 && _reductionAmount > 0
        ? ((baseline / _reductionAmount).ceil()) * _reductionDays
        : 0;
    return 'Start at $baseline/day, down to $afterOneStep after '
        '$_reductionDays days. Reach zero in ~$daysToZero days.';
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: isSelected ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon,
                  size: 36,
                  color:
                      isSelected ? scheme.onPrimaryContainer : scheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? scheme.onPrimaryContainer : null,
                        )),
                    const SizedBox(height: 4),
                    Text(description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
