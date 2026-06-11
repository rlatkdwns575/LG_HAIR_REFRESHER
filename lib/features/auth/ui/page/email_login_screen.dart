import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/api/auth_api.dart';
import '../../data/model/auth_failure.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 이메일·비밀번호 로그인 화면.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final AuthApi _authApi = const AuthApi();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('이메일과 비밀번호를 입력해 주세요.');
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authApi.signInWithEmail(email: email, password: password);
      if (!mounted) {
        return;
      }
      context.go(AppRoutePaths.home);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('로그인에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
                label: _isLoading ? '로그인 중...' : '로그인',
                enabled: !_isLoading,
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
