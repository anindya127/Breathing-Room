import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A pulsing circular button for logging a smoke.
class SmokeButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SmokeButton({super.key, required this.onPressed});

  @override
  State<SmokeButton> createState() => _SmokeButtonState();
}

class _SmokeButtonState extends State<SmokeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.mediumImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Material(
          color: scheme.error,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: scheme.error.withAlpha(100),
          child: InkWell(
            onTap: _handleTap,
            customBorder: const CircleBorder(),
            splashColor: scheme.onError.withAlpha(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smoking_rooms, size: 36, color: scheme.onError),
                const SizedBox(height: 4),
                Text(
                  'I smoked',
                  style: TextStyle(
                    color: scheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
