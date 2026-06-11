import 'package:flutter/material.dart';

/// auth 화면 공통 색상·스타일.
abstract final class AuthScreenStyles {
  static const backgroundMuted = Color(0xFFF3F5F8);
  static const primaryBlue = Color(0xFF5B6CFF);
  static const disabledButton = Color(0xFFE5E9F0);
  static const textDark = Color(0xFF111827);
  static const textMedium = Color(0xFF4B5563);
  static const textMuted = Color(0xFF9CA3AF);
  static const logoMuted = Color(0xFF9AA3AD);
  static const fieldFill = Color(0xFFF3F5F8);
  static const border = Color(0xFFD8DDE5);
  static const progressActive = Color(0xFF111827);
  static const progressInactive = Color(0xFFE5E7EB);
  static const genderSelectedBg = Color(0xFFE8EBFF);
  static const genderSelectedBorder = Color(0xFF5B6CFF);

  static const horizontalPadding = 24.0;
  static const fieldRadius = 8.0;
  static const buttonHeight = 52.0;
  static const buttonRadius = 8.0;

  static InputDecoration fieldDecoration({
    required String hintText,
    Widget? suffixIcon,
    int? maxLength,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14, color: textMuted),
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
      counterText: counterText,
    );
  }
}
