import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/auth_assets.dart';
import '../widgets/auth_screen_styles.dart';

/// 로그인 방법 선택 화면 (Google / 이메일 / 회원가입).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _emailButtonTextColor = Color(0xFF6B7280);
  static const _signupTextColor = Color(0xFF9CA3AF);
  static const _buttonHeight = 58.0;
  static const _buttonRadius = 16.0;
  static const _bottomInset = 110.0;

  void _onGoogleLogin(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: AppText('Google 로그인은 준비 중입니다.'),
          behavior: SnackBarBehavior.floating,
        ),
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
                elevation: 2,
                onPressed: () => _onGoogleLogin(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AuthAssets.googleIcon, width: 24, height: 24),
                    const SizedBox(width: 10),
                    AppText(
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
                onPressed: () => context.push(AppRoutePaths.emailLogin),
                child: AppText(
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
                onPressed: () => context.push(AppRoutePaths.signUp),
                style: TextButton.styleFrom(
                  foregroundColor: _signupTextColor,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
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

  static const _logoWidth = 228.0;
  static const _taglineWidth = 204.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AuthAssets.brandLogo,
          width: _logoWidth,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 14),
        Image.asset(
          AuthAssets.brandTagline,
          width: _taglineWidth,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
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
    this.elevation = 0,
  });

  final double height;
  final double radius;
  final Color backgroundColor;
  final Color? borderColor;
  final double elevation;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.08),
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
