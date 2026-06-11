/// [AuthApi] 호출 실패 시 UI에 표시할 메시지를 담습니다.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.isCancelled = false});

  final String message;
  final bool isCancelled;

  factory AuthFailure.cancelled() {
    return const AuthFailure('로그인이 취소되었습니다.', isCancelled: true);
  }

  @override
  String toString() => message;
}
