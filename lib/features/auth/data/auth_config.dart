import '../../../core/services/env_config.dart';

/// Google 로그인 등 auth 관련 환경 변수.
class AuthConfig {
  const AuthConfig._();

  static String? get googleWebClientId => EnvConfig.googleWebClientId;

  static bool get isGoogleSignInConfigured =>
      EnvConfig.isGoogleSignInConfigured;

  static String get oauthRedirectUrl => EnvConfig.authRedirectUrl;
}
