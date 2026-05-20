// lib/features/auth/presentation/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/widgets/app_text_field.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      suffixIcon: suffixIcon,
      onSubmitted: onSubmitted,
    );
  }
}
