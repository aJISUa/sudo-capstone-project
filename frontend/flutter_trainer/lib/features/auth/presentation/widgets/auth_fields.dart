import 'package:flutter/material.dart';

import 'package:oncare_trainer/design_system/tokens/colors.dart';
import 'package:oncare_trainer/design_system/tokens/radius.dart';
import 'package:oncare_trainer/design_system/tokens/spacing.dart';

/// Trainer brand gradient (orange) used by the auth screens. Layout /
/// widget shape mirrors the user app's auth fields, but every color is
/// read from the trainer design tokens.
const LinearGradient authBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[AppColors.primary, AppColors.secondary],
);

/// Filled, icon-prefixed text field used on the trainer login screen.
class AuthField extends StatelessWidget {
  /// Creates an auth text field.
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.onSubmitted,
    this.textInputAction,
  });

  /// Field controller.
  final TextEditingController controller;

  /// Placeholder text.
  final String hint;

  /// Leading icon.
  final IconData icon;

  /// Whether to obscure input (passwords).
  final bool obscure;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Optional trailing widget (e.g. obscure toggle).
  final Widget? trailing;

  /// Submit callback (keyboard action).
  final ValueChanged<String>? onSubmitted;

  /// Overrides the keyboard action button.
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction:
          textInputAction ??
          (onSubmitted != null ? TextInputAction.done : TextInputAction.next),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.subtleForeground, size: 20),
        suffixIcon: trailing,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

/// Full-width gradient CTA with an inline loading spinner, used by the
/// trainer login screen.
class AuthGradientButton extends StatelessWidget {
  /// Creates the gradient button.
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.loading,
  });

  /// Button label.
  final String label;

  /// Tap callback (ignored while [loading]).
  final VoidCallback onTap;

  /// Whether to show the spinner instead of the label.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: loading ? null : authBrandGradient,
            color: loading ? AppColors.inputBackground : null,
            borderRadius: const BorderRadius.all(AppRadius.lg),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primaryForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
