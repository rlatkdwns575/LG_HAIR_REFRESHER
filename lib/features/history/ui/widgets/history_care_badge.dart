import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/care_status.dart';

/// 단일 케어 상태 배지 (예: 집중권장 / 좋음).
class HistoryCareBadge extends StatelessWidget {
  const HistoryCareBadge({
    required this.status,
    this.compact = false,
    super.key,
  });

  final CareStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        softWrap: false,
        style: AppTextStyles.labelS.copyWith(
          color: status.textColor,
          fontSize: compact ? 10 : null,
        ),
      ),
    );
  }
}

/// 배지 사이 구분용 solid triangle (Figma ▶ 스타일).
class HistoryStatusArrow extends StatelessWidget {
  const HistoryStatusArrow({this.size = 12, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.play_arrow, size: size, color: AppColors.gray400);
  }
}

/// `라벨 + (이전 배지 → 이후 배지)` 한 줄.
///
/// [after] 가 없으면 단일 배지만 표시합니다(진단 기록 등).
class HistoryCareStatusRow extends StatelessWidget {
  const HistoryCareStatusRow({
    required this.label,
    required this.before,
    this.after,
    this.labelWidth = 64,
    this.beforeBadgeWidth,
    this.compact = false,
    super.key,
  });

  final String label;
  final CareStatus before;
  final CareStatus? after;

  /// 라벨 칼럼 고정 폭 (여러 줄 정렬용).
  final double labelWidth;

  /// 이전 배지 칼럼 고정 폭 — 지정하면 화살표/이후 배지가 행마다 정렬됩니다.
  final double? beforeBadgeWidth;

  /// 좁은 2열 카드용 — 라벨·배지·간격을 줄입니다.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 2.0 : 4.0;
    final beforeBadge = HistoryCareBadge(status: before, compact: compact);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: compact ? 44 : labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray700,
              fontSize: compact ? 11 : null,
            ),
          ),
        ),
        SizedBox(width: gap),
        if (beforeBadgeWidth == null)
          beforeBadge
        else
          SizedBox(
            width: beforeBadgeWidth,
            child: Align(alignment: Alignment.centerLeft, child: beforeBadge),
          ),
        if (after != null) ...[
          SizedBox(width: gap),
          HistoryStatusArrow(size: compact ? 10 : 12),
          SizedBox(width: gap),
          HistoryCareBadge(status: after!, compact: compact),
        ],
      ],
    );
  }
}
