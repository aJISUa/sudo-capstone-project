import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

/// Brand gradient shared by the auth screens (sign-in / sign-up).
const LinearGradient authBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[AppColors.primary, AppColors.secondary],
);

/// Filled, icon-prefixed text field used across the auth screens.
class AuthField extends StatelessWidget {
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

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;
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
        prefixIcon: Icon(icon, color: AppColors.mutedForeground, size: 20),
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

/// Full-width gradient CTA with an inline loading spinner, shared by the
/// sign-in and sign-up screens.
class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.loading,
  });

  final String label;
  final VoidCallback onTap;
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
            color: loading ? AppColors.muted : null,
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
                      color: Colors.white,
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
