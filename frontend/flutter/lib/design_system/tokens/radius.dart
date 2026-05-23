import 'package:flutter/painting.dart';

/// Border-radius tokens (see docs/DESIGN_TOKENS.md §4).
class AppRadius {
  AppRadius._();
  static const Radius xs = Radius.circular(4);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(24);
  static const Radius pill = Radius.circular(999);
}
