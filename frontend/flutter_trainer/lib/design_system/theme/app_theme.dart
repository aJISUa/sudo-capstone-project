import 'package:flutter/material.dart';

import 'package:oncare_trainer/design_system/tokens/colors.dart';
import 'package:oncare_trainer/design_system/tokens/typography.dart';

/// Builds the trainer app's [ThemeData] from the design tokens. Light
/// mode only for now — dark mode follows the same shape in a later phase.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.accent,
        onSecondary: AppColors.accentForeground,
        surface: AppColors.card,
        onSurface: AppColors.cardForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: AppTypography.buildTextTheme(base.textTheme),
    );
  }
}
