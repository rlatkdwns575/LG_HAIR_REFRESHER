import 'package:flutter/material.dart';

import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_text.dart';
import 'local_calendar_connect_result.dart';
import 'local_calendar_service.dart';

/// 로그인·회원가입 직후 로컬 캘린더 연동 안내.
class LocalCalendarLoginPrompt {
  LocalCalendarLoginPrompt({LocalCalendarService? calendarService})
    : calendarService = calendarService ?? LocalCalendarService();

  final LocalCalendarService calendarService;

  /// Android/iOS에서 아직 연동되지 않았을 때 안내 → OS 권한 → 동기화까지 수행합니다.
  Future<void> showIfNeeded(BuildContext context) async {
    if (!calendarService.calendarReader.isSupported) {
      return;
    }

    final status = await calendarService.fetchStatus();
    if (status.isConnected &&
        status.todayEventCount > 0 &&
        status.lastCheckedAt != null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (status.permissionGranted) {
      await _connectWithLoading(context);
      return;
    }

    final accepted = await AppConfirmDialog.show(
      context,
      title: '로컬 캘린더 연동',
      message:
          '오늘 일정을 확인해 리프레시 모드를 추천해 드려요.\n'
          '기기 캘린더 접근을 허용해 주세요.',
      primaryLabel: '허용하기',
      secondaryLabel: '나중에',
    );

    if (accepted != true || !context.mounted) {
      return;
    }

    // 앱 다이얼로그가 닫힌 뒤 OS 권한 팝업이 겹치지 않도록 한 프레임 대기합니다.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!context.mounted) {
      return;
    }

    await _connectWithLoading(context);
  }

  Future<void> _connectWithLoading(BuildContext context) async {
    if (!context.mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(height: 16),
                  AppText(
                    '캘린더 권한 확인 및\n일정 동기화 중...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    var result = await calendarService.connect();

    if (result.outcome == LocalCalendarConnectOutcome.permissionDenied &&
        context.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      result = await calendarService.connect();
    }

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!context.mounted) {
      return;
    }

    switch (result.outcome) {
      case LocalCalendarConnectOutcome.connected:
        _showSnackBar(
          context,
          result.status?.todayEventCount == 0
              ? '로컬 캘린더 연동이 완료되었습니다. 오늘 등록된 일정은 없습니다.'
              : '로컬 캘린더 연동이 완료되었습니다. '
                    '오늘 일정 ${result.status!.todayEventCount}건을 확인했습니다.',
        );
      case LocalCalendarConnectOutcome.permissionDenied:
        final retry = await AppConfirmDialog.show(
          context,
          title: '캘린더 권한 필요',
          message:
              '일정 기반 추천을 사용하려면 캘린더 접근을 허용해 주세요.\n'
              '다시 시도하거나 설정 > 로컬 캘린더에서 연동할 수 있습니다.',
          primaryLabel: '다시 시도',
          secondaryLabel: '나중에',
        );
        if (retry == true && context.mounted) {
          await _connectWithLoading(context);
        }
      case LocalCalendarConnectOutcome.syncFailed:
        _showSnackBar(
          context,
          result.errorMessage ?? '일정 동기화에 실패했습니다. 설정 > 로컬 캘린더에서 다시 시도해 주세요.',
        );
      case LocalCalendarConnectOutcome.skipped:
      case LocalCalendarConnectOutcome.cancelled:
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
