import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/auth_credentials_validator.dart';
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

  bool get _isFormValid => AuthCredentialsValidator.isSignUpFormValid(
    email: _emailController.text,
    password: _passwordController.text,
  );

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

  void _showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleNext() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = AuthCredentialsValidator.emailValidationMessage(email);
    if (emailError != null) {
      _showValidationSnackBar(emailError);
      return;
    }

    final passwordError =
        AuthCredentialsValidator.signUpPasswordValidationMessage(
          password,
          email: email,
        );
    if (passwordError != null) {
      _showValidationSnackBar(passwordError);
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
      resizeToAvoidBottomInset: true,
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
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildAuthFieldLabel('이메일을 입력해주세요.', fontSize: 18),
                      const SizedBox(height: AuthScreenStyles.fieldLabelGap),
                      buildAuthEmailField(
                        controller: _emailController,
                        hintText: '이메일 입력',
                      ),
                      const SizedBox(height: 32),
                      buildAuthFieldLabel('사용할 비밀번호를 입력해주세요.', fontSize: 18),
                      const SizedBox(height: AuthScreenStyles.fieldLabelGap),
                      buildAuthPasswordField(
                        controller: _passwordController,
                        hintText: '비밀번호 입력',
                        obscureText: _obscurePassword,
                        suffixIcon: buildPasswordVisibilityIcon(
                          obscure: _obscurePassword,
                          onToggle: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthPasswordRulesChecklist(
                        password: _passwordController.text,
                        email: _emailController.text,
                      ),
                    ],
                  ),
                ),
              ),
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
