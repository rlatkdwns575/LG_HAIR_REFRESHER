import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

/// Figma Text Field_Search (Variants > Common > Top_Header_Common Type=Search).
class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    required this.controller,
    this.hintText = '검색어를 입력하세요.',
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTextStyles.bodyM1.copyWith(
          color: AppComponentColors.fieldText,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyM1.copyWith(
            color: AppComponentColors.fieldPlaceholder,
          ),
          filled: true,
          fillColor: AppComponentColors.searchFieldBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
