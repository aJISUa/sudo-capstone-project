import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// Single button entry point so the rest of the app doesn't have to
/// pick between FilledButton / OutlinedButton / TextButton.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final Widget content = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        child: content,
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
