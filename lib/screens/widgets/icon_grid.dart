import 'package:flutter/material.dart';

/// Visual grid showing daily allowance.
/// Filled icons = smoked, outlined icons = remaining.
class IconGrid extends StatelessWidget {
  final int total;
  final int smoked;

  const IconGrid({super.key, required this.total, required this.smoked});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOver = smoked > total;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(isOver ? smoked : total, (i) {
        final isSmoked = i < smoked;
        final isExcess = isSmoked && i >= total;

        return Icon(
          isSmoked ? Icons.smoking_rooms : Icons.smoking_rooms_outlined,
          size: 28,
          color: isExcess
              ? scheme.error
              : isSmoked
                  ? scheme.onSurfaceVariant
                  : scheme.outlineVariant,
        );
      }),
    );
  }
}
