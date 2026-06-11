import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../auth_config.dart';
import '../model/auth_failure.dart';

/// Supabase Auth 기반 로그인·회원가입 API.
class AuthApi {
  const AuthApi();

  SupabaseClient get _client => SupabaseService.client;

  bool get hasSession => _client.auth.currentSession != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  GoogleSignIn? get _googleSignIn {
    final webClientId = AuthConfig.googleWebClientId;
    if (webClientId == null || webClientId.isEmpty) {
      return null;
    }

    return GoogleSignIn(serverClientId: webClientId, scopes: const ['email']);
  }

  /// Google 로그인.
  ///
  /// - [AuthConfig.isGoogleSignInConfigured] 이면 네이티브 idToken 방식
  /// - 아니면 Supabase OAuth(브라우저) 방식
  Future<void> signInWithGoogle() async {
    if (AuthConfig.isGoogleSignInConfigured) {
      await _signInWithGoogleNative();
      return;
    }

    await _signInWithGoogleOAuth();
  }

  Future<void> _signInWithGoogleNative() async {
    final googleSignIn = _googleSignIn!;

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthFailure('Google 인증 토큰을 받지 못했습니다.');
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_mapAuthError(error));
    } catch (error) {
      throw AuthFailure('Google 로그인에 실패했습니다. ($error)');
    }
  }

  Future<void> _signInWithGoogleOAuth() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AuthConfig.oauthRedirectUrl,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_mapAuthError(error));
    } catch (error) {
      throw AuthFailure('Google 로그인에 실패했습니다. ($error)');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      throw AuthFailure(_mapAuthError(error));
    }
  }

  Future<void> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'age': age, 'gender': gender},
      );
    } on AuthException catch (error) {
      throw AuthFailure(_mapAuthError(error));
    }
  }

  Future<void> signOut() async {
    final googleSignIn = _googleSignIn;
    if (googleSignIn != null) {
      await googleSignIn.signOut();
    }
    await _client.auth.signOut();
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (message.contains('email not confirmed')) {
      return '이메일 인증이 완료되지 않았습니다.';
    }
    if (message.contains('user already registered')) {
      return '이미 가입된 이메일입니다. 이메일 로그인을 이용해 주세요.';
    }
    if (message.contains('provider is not enabled') ||
        message.contains('unsupported provider')) {
      return 'Supabase에서 Google 로그인 Provider를 활성화해 주세요.';
    }

    return error.message;
  }
}
