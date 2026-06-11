import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_assets.dart';
import '../../data/model/auth_failure.dart';
import '../widgets/auth_screen_styles.dart';

/// 로그인 방법 선택 화면 (Google / 이메일 / 회원가입).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _emailButtonTextColor = Color(0xFF6B7280);
  static const _signupTextColor = Color(0xFF9CA3AF);
  static const _buttonHeight = 58.0;
  static const _buttonRadius = 16.0;
  static const _bottomInset = 110.0;

  final AuthApi _authApi = const AuthApi();

  bool _isGoogleLoading = false;

  Future<void> _onGoogleLogin() async {
    if (_isGoogleLoading) {
      return;
    }

    setState(() => _isGoogleLoading = true);

    try {
      await _authApi.signInWithGoogle();
      if (!mounted) {
        return;
      }
      if (_authApi.hasSession) {
        context.go(AppRoutePaths.home);
      }
    } on AuthFailure catch (error) {
      if (!mounted || error.isCancelled) {
        return;
      }
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('Google 로그인에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
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
      backgroundColor: AuthScreenStyles.backgroundMuted,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuthScreenStyles.horizontalPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const _LogoSection(),
              const Spacer(flex: 4),
              _LoginMethodButton(
                height: _buttonHeight,
                radius: _buttonRadius,
                backgroundColor: Colors.white,
                onPressed: _isGoogleLoading ? null : _onGoogleLogin,
                child: _isGoogleLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AuthAssets.googleIcon,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Google로 로그인하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AuthScreenStyles.textDark,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              _LoginMethodButton(
                height: _buttonHeight,
                radius: _buttonRadius,
                backgroundColor: Colors.transparent,
                borderColor: AuthScreenStyles.border,
                onPressed: _isGoogleLoading
                    ? null
                    : () => context.push(AppRoutePaths.emailLogin),
                child: const Text(
                  '이메일로 로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _emailButtonTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              TextButton(
                onPressed: _isGoogleLoading
                    ? null
                    : () => context.push(AppRoutePaths.signUp),
                style: TextButton.styleFrom(
                  foregroundColor: _signupTextColor,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: _bottomInset),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '서비스 logo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AuthScreenStyles.logoMuted,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '서비스 설명',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AuthScreenStyles.logoMuted,
          ),
        ),
      ],
    );
  }
}

class _LoginMethodButton extends StatelessWidget {
  const _LoginMethodButton({
    required this.height,
    required this.radius,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor,
  });

  final double height;
  final double radius;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}
