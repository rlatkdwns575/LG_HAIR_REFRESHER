import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_credentials_validator.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 이메일·비밀번호 로그인 화면.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _authApi = const AuthApi();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _isFormValid => AuthCredentialsValidator.isLoginFormValid(
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
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = AuthCredentialsValidator.emailValidationMessage(email);
    if (emailError != null) {
      _showValidationSnackBar(emailError);
      return;
    }

    final passwordError = AuthCredentialsValidator.passwordValidationMessage(
      password,
    );
    if (passwordError != null) {
      _showValidationSnackBar(passwordError);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authApi.signIn(email: email, password: password);
      if (!mounted) {
        return;
      }
      context.go(AppRoutePaths.home);
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
              const AuthCloseHeader(title: '로그인'),
              const SizedBox(height: 28),
              buildAuthFieldLabel('아이디(이메일)'),
              const SizedBox(height: 8),
              buildAuthEmailField(
                controller: _emailController,
                hintText: '이메일 입력',
              ),
              const SizedBox(height: 22),
              buildAuthFieldLabel('비밀번호'),
              const SizedBox(height: 8),
              buildAuthPasswordField(
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
              const Spacer(),
              AuthPrimaryButton(
                label: _isSubmitting ? '로그인 중...' : '로그인',
                enabled: !_isSubmitting && _isFormValid,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
