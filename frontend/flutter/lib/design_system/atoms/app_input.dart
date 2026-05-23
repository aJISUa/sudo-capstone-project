import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/radius.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscure;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
      ),
    );
  }
}
