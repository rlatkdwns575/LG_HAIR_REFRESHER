import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/auth_user_profile.dart';
import '../model/sign_up_draft.dart';

class AuthApi {
  const AuthApi();

  static const _profileColumns =
      'user_id, email, nickname, age, gender';

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
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthApiException('로그인에 실패했습니다.');
      }
    } on AuthException catch (error) {
      throw AuthApiException(error.message);
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthApiException(error.message);
    }
  }

  Future<void> signUp(SignUpDraft draft) async {
    if (!draft.isReadyToSubmit) {
      throw const AuthApiException('회원가입 정보가 충분하지 않습니다.');
    }

    try {
      final authResponse = await SupabaseService.client.auth.signUp(
        email: draft.email,
        password: draft.password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthApiException('Supabase Auth 사용자 생성에 실패했습니다.');
      }

      final profile = AuthUserProfile(
        userId: user.id,
        email: draft.email,
        nickname: draft.nickname!,
        age: draft.age!,
        gender: draft.gender!,
      );

      await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .insert(profile.toInsertJson());
    } on AuthException catch (error) {
      throw AuthApiException(error.message);
    } on PostgrestException catch (error) {
      throw AuthApiException('프로필 저장에 실패했습니다. (${error.message})');
    }
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
