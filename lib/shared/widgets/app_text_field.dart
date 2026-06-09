import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

enum AppTextFieldState { empty, typing, completed }

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.state = AppTextFieldState.empty,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final AppTextFieldState state;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final showClear = state == AppTextFieldState.typing && hasText;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: AppTextStyles.bodyM1.copyWith(
          color: state == AppTextFieldState.empty
              ? AppComponentColors.fieldPlaceholder
              : AppComponentColors.fieldText,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'text',
          hintStyle: AppTextStyles.bodyM1.copyWith(
            color: AppComponentColors.fieldPlaceholder,
          ),
          filled: true,
          fillColor: AppComponentColors.fieldBackground,
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
          suffixIcon: showClear
              ? IconButton(
                  onPressed: onClear,
                  icon: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppComponentColors.fieldClearBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 10,
                      color: AppComponentColors.fieldClearIcon,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
