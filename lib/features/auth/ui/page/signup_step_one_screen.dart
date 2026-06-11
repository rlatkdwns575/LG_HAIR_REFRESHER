import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/model/sign_up_draft.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 회원가입 1단계 — 이메일·비밀번호 입력.
class SignUpStepOneScreen extends StatefulWidget {
  const SignUpStepOneScreen({super.key});

  @override
  State<SignUpStepOneScreen> createState() => _SignUpStepOneScreenState();
}

class _SignUpStepOneScreenState extends State<SignUpStepOneScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _emailController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  void _handleNext() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('이메일과 비밀번호를 입력해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.push(
      AppRoutePaths.signUpStepTwo,
      extra: SignUpDraft(email: email, password: password),
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
              AuthCloseHeader(
                title: '회원가입',
                onClose: () => context.go(AppRoutePaths.login),
              ),
              const SizedBox(height: 12),
              const AuthSignupProgressLine(step: 1),
              const SizedBox(height: 36),
              buildAuthFieldLabel('이메일을 입력해주세요.', fontSize: 18),
              const SizedBox(height: 12),
              buildAuthTextField(
                controller: _emailController,
                hintText: '이메일 입력',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              buildAuthFieldLabel('사용할 비밀번호를 입력해주세요.', fontSize: 18),
              const SizedBox(height: 12),
              buildAuthTextField(
                controller: _passwordController,
                hintText: '비밀번호 입력',
                obscureText: _obscurePassword,
                suffixIcon: buildPasswordVisibilityIcon(
                  obscure: _obscurePassword,
                  onToggle: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '* 비밀번호 조건',
                style: TextStyle(
                  fontSize: 12,
                  color: AuthScreenStyles.textMuted,
                ),
              ),
              const Spacer(),
              AuthPrimaryButton(
                label: '다음',
                enabled: _isFormValid,
                onPressed: _handleNext,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
