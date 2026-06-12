import 'app_env.dart';
import 'supabase_service.dart';

/// Supabase Auth 세션에서 현재 사용자 ID를 해석합니다.
class AuthSessionService {
  const AuthSessionService._();

  static String? get currentUserId =>
      SupabaseService.client.auth.currentUser?.id;

  /// 로그인 사용자 ID를 우선 사용하고, 없으면 개발용 `DEV_USER_ID`로 대체합니다.
  static String resolveUserId({String? override}) {
    final resolved = (override ?? currentUserId ?? AppEnv.devUserId).trim();
    if (resolved.isEmpty) {
      throw StateError('로그인된 사용자가 없고 DEV_USER_ID도 설정되지 않았습니다.');
    }
    return resolved;
  }
}
