import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/auth_user_profile.dart';
import '../model/sign_up_draft.dart';

class AuthApi {
  const AuthApi();

  static const _profileColumns = 'user_id, email, nickname, age, gender';

  /// `AUTH_USERS` 프로필을 조회합니다.
  Future<AuthUserProfile?> fetchProfile({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select(_profileColumns)
          .eq('user_id', resolvedUserId)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      return AuthUserProfile.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException {
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthApiException('로그인에 실패했습니다.');
      }
    } on AuthException catch (error) {
      throw AuthApiException(AuthApiException.fromAuthException(error));
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthApiException(error.message);
    }
  }

  Future<AuthSignUpResult> signUp(SignUpDraft draft) async {
    if (!draft.isReadyToSubmit) {
      throw const AuthApiException('회원가입 정보가 충분하지 않습니다.');
    }

    try {
      final authResponse = await SupabaseService.client.auth.signUp(
        email: draft.email.trim(),
        password: draft.password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthApiException('Supabase Auth 사용자 생성에 실패했습니다.');
      }

      final profile = AuthUserProfile(
        userId: user.id,
        email: draft.email.trim(),
        nickname: draft.nickname!,
        age: draft.age!,
        gender: draft.gender!,
      );

      await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .insert(profile.toInsertJson());

      return AuthSignUpResult(
        userId: user.id,
        sessionCreated: authResponse.session != null,
      );
    } on AuthException catch (error) {
      throw AuthApiException(AuthApiException.fromAuthException(error));
    } on PostgrestException catch (error) {
      throw AuthApiException('프로필 저장에 실패했습니다. (${error.message})');
    }
  }
}

/// 회원가입 결과. [sessionCreated]가 false면 이메일 인증 후 로그인이 필요합니다.
class AuthSignUpResult {
  const AuthSignUpResult({required this.userId, required this.sessionCreated});

  final String userId;
  final bool sessionCreated;
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  static String fromAuthException(AuthException error) {
    final normalized = error.message.toLowerCase();

    if (normalized.contains('email not confirmed')) {
      return '이메일 인증이 필요합니다. 가입 시 받은 메일의 확인 링크를 눌러주세요.';
    }
    if (normalized.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다. '
          'Supabase Authentication에 등록된 계정 정보를 확인해주세요.';
    }
    if (normalized.contains('user already registered')) {
      return '이미 가입된 이메일입니다. 로그인하거나 다른 이메일을 사용해주세요.';
    }
    if (normalized.contains('password')) {
      return '비밀번호 조건을 확인해주세요. (${error.message})';
    }

    return error.message;
  }

  @override
  String toString() => message;
}
