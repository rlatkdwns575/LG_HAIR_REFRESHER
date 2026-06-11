import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 이메일·비밀번호 로그인 화면.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
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

    context.go(AppRoutePaths.home);
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
              buildAuthTextField(
                controller: _emailController,
                hintText: '이메일 입력',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              buildAuthFieldLabel('비밀번호'),
              const SizedBox(height: 8),
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
              const Spacer(),
              AuthPrimaryButton(
                label: '로그인',
                enabled: true,
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
