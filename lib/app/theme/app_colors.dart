import 'package:flutter/material.dart';

/// Figma Design System > Color Style.
class AppColors {
  const AppColors._();

  // Gray
  static const gray0 = Color(0xFFFFFFFF);
  static const gray50 = Color(0xFFF5F7FA);
  static const gray100 = Color(0xFFEFF1F4);
  static const gray200 = Color(0xFFE6E9ED);
  static const gray300 = Color(0xFFDADEE3);
  static const gray400 = Color(0xFFB3BAC4);
  static const gray500 = Color(0xFF8B939E);
  static const gray600 = Color(0xFF5D6674);
  static const gray700 = Color(0xFF4E5561);
  static const gray800 = Color(0xFF313842);
  static const gray900 = Color(0xFF171B21);
  static const gray1000 = Color(0xFF000000);

  // Primary
  static const primary100 = Color(0xFFF5F6FF);
  static const primary200 = Color(0xFFEBEDFF);
  static const primary300 = Color(0xFFE0E5FF);
  static const primary400 = Color(0xFF7E8DFF);
  static const primary500 = Color(0xFF5D70FF);
  static const primary700 = Color(0xFF323EA6);
  static const primary900 = Color(0xFF052C66);

  static const primaryGradient500 = LinearGradient(
    begin: Alignment(-0.2, 0.9),
    end: Alignment(0.8, 0.1),
    colors: [Color(0xFF5D70FF), Color(0xFF8694FF)],
  );

  // Safe
  static const safe100 = Color(0xFFE4F2F1);
  static const safe500 = Color(0xFF07B3A8);

  // Warning
  static const warning100 = Color(0xFFFFF0ED);
  static const warning500 = Color(0xFFDD2C05);

  // Blue
  static const blue100 = Color(0xFFEFF6FF);
  static const blue200 = Color(0xFFE2EDFC);
  static const blue300 = Color(0xFFCBDFFA);
  static const blue700 = Color(0xFF217CF9);
  static const blue800 = Color(0xFF135FCD);
  static const blue900 = Color(0xFF0B4596);

  // Green
  static const green100 = Color(0xFFEDFAF6);
  static const green200 = Color(0xFFD9F6E9);
  static const green300 = Color(0xFFB9E9D2);
  static const green700 = Color(0xFF079171);
  static const green800 = Color(0xFF00745F);
  static const green900 = Color(0xFF075445);

  // Orange
  static const orange100 = Color(0xFFFFF2EC);
  static const orange200 = Color(0xFFFFE8DB);
  static const orange300 = Color(0xFFFFD5C0);
  static const orange600 = Color(0xFFFF6600);
  static const orange700 = Color(0xFFFF5700);

  // Red
  static const red100 = Color(0xFFFDF0F0);
  static const red200 = Color(0xFFFDE7E7);
  static const red300 = Color(0xFFFED4D2);
  static const red700 = Color(0xFFFA342C);
  static const red800 = Color(0xFFCA1D13);
  static const red900 = Color(0xFF921708);

  // Yellow
  static const yellow700 = Color(0xFFEFB300);

  // Presentation
  static const presentationBlack = Color(0xFF1E1E1E);
  static const presentationGray80 = Color(0xFF757575);
  static const presentationGray60 = Color(0xFF9A9A9A);
  static const presentationGray30 = Color(0xFFD7DADE);
  static const presentationBox = Color(0xFFF4F5F7);
  static const presentationPointRed = Color(0xFFFF2366);
  static const presentationSubRed = Color(0xFFFF5C8E);

  // Semantic aliases
  static const primary = primary500;
  static const primaryContainer = primary100;
  static const background = gray50;
  static const surface = gray0;
  static const textPrimary = gray900;
  static const textSecondary = gray600;
  static const divider = gray300;
  static const success = safe500;
  static const warning = warning500;
  static const error = red700;
}
