import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_radio.dart';
import '../../data/api/auth_api.dart';
import '../../data/model/hair_profile_options.dart';
import '../../data/model/sign_up_draft.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 회원가입 3단계 — 모발 길이·모발 유형 선택.
class SignUpStepThreeScreen extends StatefulWidget {
  const SignUpStepThreeScreen({required this.draft, super.key});

  final SignUpDraft draft;

  @override
  State<SignUpStepThreeScreen> createState() => _SignUpStepThreeScreenState();
}

class _SignUpStepThreeScreenState extends State<SignUpStepThreeScreen> {
  final _authApi = const AuthApi();

  String? _selectedHairLength;
  String? _selectedHairType;
  bool _isSubmitting = false;

  bool get _isFormValid =>
      _selectedHairLength != null && _selectedHairType != null;

  Future<void> _handleSignUpComplete() async {
    if (!_isFormValid || _isSubmitting) {
      return;
    }

    final draft = widget.draft.copyWith(
      hairLength: _selectedHairLength,
      hairType: _selectedHairType,
    );

    setState(() => _isSubmitting = true);

    try {
      await _authApi.signUp(draft);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.go(AppRoutePaths.login);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildRadioGroup({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAuthFieldLabel(title, fontSize: 18),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _HairProfileRadioTile(
            label: options[i],
            groupValue: selected,
            onTap: () => onSelected(options[i]),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuthScreenStyles.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthCloseHeader(title: '회원가입'),
              const SizedBox(height: 12),
              const AuthSignupProgressLine(step: 3),
              const SizedBox(height: 36),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRadioGroup(
                        title: '모발 길이를 선택해주세요.',
                        options: HairProfileOptions.hairLengths,
                        selected: _selectedHairLength,
                        onSelected: (value) =>
                            setState(() => _selectedHairLength = value),
                      ),
                      const SizedBox(height: 32),
                      _buildRadioGroup(
                        title: '모발 유형을 선택해주세요.',
                        options: HairProfileOptions.hairTypes,
                        selected: _selectedHairType,
                        onSelected: (value) =>
                            setState(() => _selectedHairType = value),
                      ),
                    ],
                  ),
                ),
              ),
              AuthPrimaryButton(
                label: _isSubmitting ? '가입 중...' : '확인',
                enabled: _isFormValid && !_isSubmitting,
                onPressed: _handleSignUpComplete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HairProfileRadioTile extends StatelessWidget {
  const _HairProfileRadioTile({
    required this.label,
    required this.groupValue,
    required this.onTap,
  });

  final String label;
  final String? groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthScreenStyles.fieldFill,
      borderRadius: BorderRadius.circular(AuthScreenStyles.fieldRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              AppRadio<String>(
                value: label,
                groupValue: groupValue,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AuthScreenStyles.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
