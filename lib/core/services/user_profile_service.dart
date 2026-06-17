import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';
import '../models/user_hair_profile.dart';
import 'auth_session_service.dart';
import 'supabase_service.dart';

class UserProfileServiceException implements Exception {
  const UserProfileServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// `AUTH_USERS` 모발 유형 조회·저장.
class UserProfileService {
  const UserProfileService();

  static const _hairProfileColumns = 'hair_type';
  static const _profileKeyColumns = 'user_id';

  Future<UserHairProfile?> fetchHairProfile({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select(_hairProfileColumns)
          .eq('user_id', resolvedUserId)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      return UserHairProfile.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException {
      return null;
    }
  }

  Future<void> saveHairProfile({
    required String hairType,
    String? userId,
  }) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    try {
      if (await _profileExists(resolvedUserId)) {
        await _applyHairTypeUpdate(userId: resolvedUserId, hairType: hairType);
        return;
      }

      try {
        await _insertProfileWithHairType(
          userId: resolvedUserId,
          hairType: hairType,
        );
      } on PostgrestException catch (error) {
        if (!_isDuplicateProfileError(error)) {
          rethrow;
        }
        await _applyHairTypeUpdate(userId: resolvedUserId, hairType: hairType);
      }
    } on UserProfileServiceException {
      rethrow;
    } on PostgrestException catch (error) {
      throw UserProfileServiceException(
        _messageFromPostgrest(error, userId: resolvedUserId),
      );
    }
  }

  Future<bool> _profileExists(String userId) async {
    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select(_profileKeyColumns)
          .eq('user_id', userId)
          .maybeSingle();
      return row != null;
    } on PostgrestException {
      return false;
    }
  }

  Future<void> _applyHairTypeUpdate({
    required String userId,
    required String hairType,
  }) async {
    await SupabaseService.client
        .from(SupabaseTables.authUsers)
        .update({'hair_type': hairType})
        .eq('user_id', userId);

    final saved = await fetchHairProfile(userId: userId);
    if (saved?.hairType != hairType) {
      throw const UserProfileServiceException(
        'AUTH_USERS에 모발 유형을 저장할 UPDATE 권한이 없습니다. '
        'Supabase SQL Editor에서 AUTH_USERS UPDATE 정책을 확인해주세요.',
      );
    }

    if (kDebugMode) {}
  }

  Future<void> _insertProfileWithHairType({
    required String userId,
    required String hairType,
  }) async {
    final authUser = SupabaseService.client.auth.currentUser;
    if (authUser == null || authUser.id != userId) {
      throw UserProfileServiceException(_missingProfileMessage(userId));
    }

    final email = authUser.email?.trim();
    if (email == null || email.isEmpty) {
      throw const UserProfileServiceException(
        '로그인 계정에 이메일 정보가 없어 프로필을 생성할 수 없습니다.',
      );
    }

    await SupabaseService.client.from(SupabaseTables.authUsers).insert({
      'user_id': userId,
      'email': email,
      'nickname': _nicknameFromEmail(email),
      'age': 0,
      'gender': '기타',
      'hair_type': hairType,
    });

    if (kDebugMode) {}
  }

  static String _missingProfileMessage(String userId) {
    final isLoggedIn = AuthSessionService.currentUserId != null;
    if (isLoggedIn) {
      return 'AUTH_USERS에 로그인 계정(user_id=$userId) 프로필이 없습니다. '
          '회원가입 2단계를 완료했는지 확인해주세요.';
    }

    return 'AUTH_USERS에 user_id=$userId 프로필이 없습니다. '
        '로그인하거나 .env의 DEV_USER_ID를 AUTH_USERS.user_id와 맞춰주세요.';
  }

  static bool _isDuplicateProfileError(PostgrestException error) {
    final message = error.message.toLowerCase();
    return message.contains('duplicate key') || message.contains('unique');
  }

  static String _messageFromPostgrest(
    PostgrestException error, {
    required String userId,
  }) {
    final message = error.message.toLowerCase();
    if (message.contains('permission denied') ||
        error.code == '42501' ||
        message.contains('row-level security')) {
      return 'AUTH_USERS 저장 권한이 없습니다. '
          'Supabase SQL Editor에서 AUTH_USERS UPDATE/INSERT 정책을 확인해주세요.';
    }
    return '모발 정보 저장에 실패했습니다. (${error.message})';
  }

  static String _nicknameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return '사용자';
    }
    return localPart;
  }
}
