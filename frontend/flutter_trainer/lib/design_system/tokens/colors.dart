import 'package:flutter/painting.dart';

/// Trainer-app palette. Derived from the On-Care Figma trainer mock
/// (`On-Care_figma/src/app/App.tsx`, TrainerApp section). The trainer
/// experience is branded **orange** (vs. the user app's teal-blue),
/// while blue is kept as the accent used for client avatars / info chips.
///
/// Values are picked to match the mock and are the single source of
/// truth — widgets must read from here (STRUCTURE.md §2.5: no hardcoded
/// colors).
class AppColors {
  AppColors._();

  // --- Brand (trainer = orange) ---
  /// Primary orange used for CTAs / active nav / trainer accents.
  static const Color primary = Color(0xFFFF7A45);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Secondary orange (gradient second stop in the mock's stat cards).
  static const Color secondary = Color(0xFFFF953C);
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  // --- Accent (client blue) ---
  /// Blue used for client avatars, info chips, and the "AI 요약" card.
  static const Color accent = Color(0xFF3EAFDF);
  static const Color accentForeground = Color(0xFFFFFFFF);

  /// Deeper blue — second stop of the client-avatar gradient.
  static const Color accentDark = Color(0xFF2A8FBD);

  // --- Surface / text ---
  /// App canvas behind cards (mock uses `#F8FAFC`).
  static const Color background = Color(0xFFF8FAFC);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1A1A);

  /// Primary text.
  static const Color foreground = Color(0xFF1A1A1A);

  /// Secondary body text (slate-ish `#5A6A7A`).
  static const Color mutedForeground = Color(0xFF5A6A7A);

  /// Tertiary / placeholder text (`#A0A8B5`).
  static const Color subtleForeground = Color(0xFFA0A8B5);

  /// Disabled / hairline text (`#C0CDD6`).
  static const Color disabledForeground = Color(0xFFC0CDD6);

  // --- Semantic ---
  /// Success / "완료" green (`#34C759`).
  static const Color success = Color(0xFF34C759);
  static const Color successForeground = Color(0xFFFFFFFF);

  /// Warning / "나트륨 초과" orange (`#FF953C`).
  static const Color warning = Color(0xFFFF953C);
  static const Color warningForeground = Color(0xFFFFFFFF);

  /// Destructive / delete red (`#FF3B30`).
  static const Color destructive = Color(0xFFFF3B30);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // --- Borders & fills ---
  /// Card hairline border (`rgba(0,0,0,0.05)`).
  static const Color border = Color(0x0D000000);

  /// Stronger divider / input border (`#E8EFF5`).
  static const Color borderStrong = Color(0xFFE8EFF5);

  /// Soft blue-grey fill for input backgrounds / list rows (`#F2F4F7`).
  static const Color inputBackground = Color(0xFFF2F4F7);

  /// Blue-tinted fill used behind client sub-sections (`#F2F9FB`).
  static const Color accentSurface = Color(0xFFF2F9FB);
}
