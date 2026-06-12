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
/// [showArrow] 가 false 이면 화살표 없이 이전 배지만 표시합니다.
class HistoryCareStatusRow extends StatelessWidget {
  const HistoryCareStatusRow({
    required this.label,
    required this.before,
    this.after,
    this.labelWidth = 64,
    this.beforeBadgeWidth,
    this.compact = false,
    this.showArrow = true,
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

  /// false 이면 [HistoryCareStatusGroup] 등에서 공용 화살표를 쓸 때 사용합니다.
  final bool showArrow;

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
        if (after != null && showArrow) ...[
          SizedBox(width: gap),
          HistoryStatusArrow(size: compact ? 10 : 12),
          SizedBox(width: gap),
          HistoryCareBadge(status: after!, compact: compact),
        ],
      ],
    );
  }
}

/// 냄새·먼지 등 여러 케어 상태를 **화살표 1개**로 연결해 표시합니다.
class HistoryCareStatusGroup extends StatelessWidget {
  const HistoryCareStatusGroup({
    required this.items,
    this.labelWidth = 58,
    this.compact = false,
    super.key,
  });

  final List<HistoryCareStatusItem> items;
  final double labelWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final gap = compact ? 2.0 : 4.0;
    final rowSpacing = compact ? 6.0 : 8.0;
    final rowHeight = compact ? 20.0 : 22.0;
    final arrowSize = compact ? 10.0 : 12.0;
    final showArrow = items.any((item) => item.after != null);

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(height: rowSpacing),
                SizedBox(
                  height: rowHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: HistoryCareStatusRow(
                      label: items[i].label,
                      before: items[i].before,
                      after: items[i].after,
                      labelWidth: labelWidth,
                      compact: compact,
                      showArrow: false,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (showArrow) ...[
            SizedBox(width: gap),
            Center(child: HistoryStatusArrow(size: arrowSize)),
            SizedBox(width: gap),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) SizedBox(height: rowSpacing),
                  _AfterBadgeSlot(
                    after: items[i].after,
                    compact: compact,
                    rowHeight: rowHeight,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HistoryCareStatusItem {
  const HistoryCareStatusItem({
    required this.label,
    required this.before,
    this.after,
  });

  final String label;
  final CareStatus before;
  final CareStatus? after;
}

class _AfterBadgeSlot extends StatelessWidget {
  const _AfterBadgeSlot({
    required this.after,
    required this.compact,
    required this.rowHeight,
  });

  final CareStatus? after;
  final bool compact;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: after == null
            ? const SizedBox.shrink()
            : HistoryCareBadge(status: after!, compact: compact),
      ),
    );
  }
}
