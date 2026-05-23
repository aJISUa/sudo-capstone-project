import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/typography.dart';

/// Builds the app-wide `ThemeData` for light and dark mode. All colour
/// roles flow from the seed `AppColors.primary` via Material 3's
/// `ColorScheme.fromSeed`, so any Figma palette update only needs to
/// touch `colors.dart`.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return base.copyWith(
      textTheme: AppTypography.buildTextTheme(base.textTheme),
    );
  }
}
