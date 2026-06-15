import '../../../../shared/widgets/app_badge.dart';
import 'measure_result_detail_metric.dart';

/// 냄새/먼지/모발 상태 상세 섹션.
class MeasureResultDetailSection {
  const MeasureResultDetailSection({
    required this.title,
    required this.subtitle,
    required this.analysisBadgeLabel,
    required this.analysisBadgeVariant,
    required this.analysisDescription,
    required this.metrics,
    this.typeTags = const [],
  });

  final String title;
  final String subtitle;
  final String analysisBadgeLabel;
  final AppBadgeSmallVariant analysisBadgeVariant;
  final String analysisDescription;
  final List<MeasureResultDetailMetric> metrics;
  final List<String> typeTags;
}
