import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/typography.dart';

/// Builds the app-wide `ThemeData`. The light scheme is hand-mapped from
/// the original prototype's `theme.css` so the look matches 1:1; dark
/// mode falls back to a derived ColorScheme.fromSeed for now and will
/// be tightened in a later phase.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: AppColors.accent,
      onPrimaryContainer: AppColors.accentForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      secondaryContainer: AppColors.accent,
      onSecondaryContainer: AppColors.accentForeground,
      tertiary: AppColors.secondary,
      onTertiary: AppColors.secondaryForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: AppColors.destructive,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.inputBackground,
      surfaceContainerHigh: AppColors.accent,
      surfaceContainerHighest: AppColors.muted,
      onSurfaceVariant: AppColors.mutedForeground,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      surfaceTint: AppColors.primary,
      inverseSurface: AppColors.foreground,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.accent,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return base.copyWith(
      textTheme: AppTypography.buildTextTheme(base.textTheme),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return base.copyWith(
      textTheme: AppTypography.buildTextTheme(base.textTheme),
    );
  }
}
