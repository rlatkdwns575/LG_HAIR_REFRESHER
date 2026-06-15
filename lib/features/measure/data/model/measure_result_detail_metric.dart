import '../../../../shared/widgets/app_badge.dart';

/// 진단 상세 화면의 지표 행 (잔여 냄새 수준 등).
class MeasureResultDetailMetric {
  const MeasureResultDetailMetric({
    required this.label,
    required this.badgeLabel,
    required this.badgeVariant,
    this.tagLabels = const [],
    this.showHelpIcon = false,
    this.helpMessage,
  });

  final String label;
  final String badgeLabel;
  final AppBadgeSmallVariant badgeVariant;
  final List<String> tagLabels;
  final bool showHelpIcon;
  final String? helpMessage;
}
