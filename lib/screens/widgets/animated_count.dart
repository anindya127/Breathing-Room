import 'package:flutter/material.dart';

/// Smoothly animates between number values.
class AnimatedCount extends StatelessWidget {
  final int count;
  final TextStyle? style;

  const AnimatedCount({super.key, required this.count, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: count, end: count),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            '$count',
            key: ValueKey(count),
            style: style,
          ),
        );
      },
    );
  }
}
