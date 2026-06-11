import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_screen_styles.dart';

class AuthCloseHeader extends StatelessWidget {
  const AuthCloseHeader({required this.title, this.onClose, super.key});

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose ?? () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AuthScreenStyles.textDark,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AuthScreenStyles.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthSignupProgressLine extends StatelessWidget {
  const AuthSignupProgressLine({required this.step, super.key});

  /// 1 또는 2
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            color: step == 1
                ? AuthScreenStyles.progressActive
                : AuthScreenStyles.progressInactive,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: step == 2
                ? AuthScreenStyles.progressActive
                : AuthScreenStyles.progressInactive,
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthScreenStyles.buttonHeight,
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AuthScreenStyles.primaryBlue,
          disabledBackgroundColor: AuthScreenStyles.disabledButton,
          foregroundColor: Colors.white,
          disabledForegroundColor: AuthScreenStyles.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthScreenStyles.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

Widget buildAuthFieldLabel(String text, {double fontSize = 14}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: AuthScreenStyles.textMedium,
    ),
  );
}

Widget buildAuthTextField({
  required TextEditingController controller,
  required String hintText,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  Widget? suffixIcon,
  int? maxLength,
  ValueChanged<String>? onChanged,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLength: maxLength,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 14, color: AuthScreenStyles.textDark),
    decoration: AuthScreenStyles.fieldDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      counterText: maxLength == null ? null : '',
    ),
  );
}

Widget buildPasswordVisibilityIcon({
  required bool obscure,
  required VoidCallback onToggle,
}) {
  return IconButton(
    onPressed: onToggle,
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 20,
      color: AuthScreenStyles.textMuted,
    ),
  );
}
