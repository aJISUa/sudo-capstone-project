import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-controlled `ThemeMode`. Defaults to following the system
/// setting; can be toggled by a UI control (Stage 4 lands the
/// settings page that mutates this).
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.system,
  name: 'themeMode',
);
