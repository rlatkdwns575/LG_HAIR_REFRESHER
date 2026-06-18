import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../data/auth_credentials_validator.dart';
import 'auth_screen_styles.dart';

class AuthCloseHeader extends StatelessWidget {
  const AuthCloseHeader({required this.title, this.onClose, super.key});

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    const closeIconSize = 20.0;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: AppCommonTopHeader.backIconSlotWidth,
            height: closeIconSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onClose ?? () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: closeIconSize,
                  minHeight: closeIconSize,
                ),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.close,
                  size: closeIconSize,
                  color: AuthScreenStyles.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppCommonTopHeader.backToTitleGap),
          AppText(
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

  /// 1, 2
  final int step;

  static const _totalSteps = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _totalSteps; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 2,
              color: step >= i + 1
                  ? AuthScreenStyles.progressActive
                  : AuthScreenStyles.progressInactive,
            ),
          ),
        ],
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
        child: AppText(label),
      ),
    );
  }
}

Widget buildAuthFieldLabel(String text, {double fontSize = 14}) {
  return AppText(
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
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLength: maxLength,
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    style: const TextStyle(fontSize: 14, color: AuthScreenStyles.textDark),
    decoration: AuthScreenStyles.fieldDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      counterText: maxLength == null ? null : '',
    ),
  );
}

Widget buildAuthEmailField({
  required TextEditingController controller,
  required String hintText,
  ValueChanged<String>? onChanged,
}) {
  return buildAuthTextField(
    controller: controller,
    hintText: hintText,
    keyboardType: TextInputType.emailAddress,
    onChanged: onChanged,
    inputFormatters: [AuthCredentialsValidator.denyKoreanInputFormatter],
  );
}

Widget buildAuthPasswordField({
  required TextEditingController controller,
  required String hintText,
  required bool obscureText,
  required Widget suffixIcon,
  ValueChanged<String>? onChanged,
}) {
  return buildAuthTextField(
    controller: controller,
    hintText: hintText,
    obscureText: obscureText,
    onChanged: onChanged,
    inputFormatters: [AuthCredentialsValidator.denyKoreanInputFormatter],
    suffixIcon: suffixIcon,
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

/// 회원가입 비밀번호 조건 실시간 체크리스트.
///
/// 각 조건은 충족되면 파란색으로 표시됩니다.
class AuthPasswordRulesChecklist extends StatelessWidget {
  const AuthPasswordRulesChecklist({
    required this.password,
    required this.email,
    super.key,
  });

  final String password;
  final String email;

  @override
  Widget build(BuildContext context) {
    final statuses = AuthCredentialsValidator.evaluateSignUpPassword(
      password,
      email: email,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final status in statuses)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: status.satisfied
                      ? AuthScreenStyles.primaryBlue
                      : AuthScreenStyles.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: AppText(
                    status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: status.satisfied
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: status.satisfied
                          ? AuthScreenStyles.primaryBlue
                          : AuthScreenStyles.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
