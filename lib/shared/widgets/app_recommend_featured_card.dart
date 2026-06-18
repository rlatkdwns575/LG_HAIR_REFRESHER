import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/image_assets.dart';
import '../../shared/recommendation/refresh_recommend_basis.dart';
import 'app_box_button.dart';
import 'app_text.dart';

/// Figma 맞춤 리프레시 / 기록 루틴 추천 카드.
///
/// 아이콘 + 제목·본문 + 파란 메타 태그 + 하단 CTA 버튼. 테두리 없음.
class AppRecommendFeaturedCard extends StatelessWidget {
  const AppRecommendFeaturedCard({
    required this.headline,
    required this.body,
    required this.metaTags,
    required this.actionLabel,
    this.onAction,
    this.actionButtonHeight = 40,
    this.iconAsset = ImageAssets.homeRecommendSparkleIcon,
    super.key,
  });

  final String headline;
  final String body;
  final List<String> metaTags;
  final String actionLabel;
  final VoidCallback? onAction;
  final double actionButtonHeight;
  final String iconAsset;

  static const _iconSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconAsset,
                width: _iconSize,
                height: _iconSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      headline,
                      style: AppTextStyles.bodyM2.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      body,
                      style: AppTextStyles.titleXs.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (metaTags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final tag in metaTags)
                  AppText(
                    tag,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppBoxButton(
            label: actionLabel,
            height: actionButtonHeight,
            onPressed: onAction,
            variant: onAction == null
                ? AppBoxButtonVariant.disabled
                : AppBoxButtonVariant.active,
          ),
        ],
      ),
    );
  }
}

/// 추천 카드 본문 — Figma 고정 카피.
const recommendFeaturedCardBody =
    '리프레시 전, 현재 상태를 먼저 확인해보세요.\n'
    '지금 필요한 리프레시를 추천해드릴게요.';

/// AI/규칙 추천 메시지에서 **환경·일정 분석 한 줄**만 추출합니다.
///
/// 두 번째 줄(모드 추천 문구)은 키워드 영역의 모드명으로 분리합니다.
String extractRecommendAnalysisHeadline(
  String message, {
  RefreshRecommendBasis? basis,
}) {
  final lines = message
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    return _fallbackHeadline(basis);
  }

  var headline = lines.first;
  if (headline.contains('리프레시 모드를 추천')) {
    headline = headline.split('리프레시 모드를 추천').first.trim();
  }

  if (headline.endsWith('니,')) {
    return headline.replaceFirst(RegExp(r'니,$'), '에요.');
  }
  if (headline.endsWith(',')) {
    return switch (basis) {
      RefreshRecommendBasis.measure => '측정 결과와 오늘 환경을 분석했어요.',
      RefreshRecommendBasis.weatherAndSchedule => '오늘 일정과 날씨를 분석했어요.',
      RefreshRecommendBasis.weatherOnly ||
      null => headline.replaceFirst(RegExp(r',$'), ' 하루에요.'),
    };
  }
  if (!headline.endsWith('요.') && !headline.endsWith('요')) {
    return '$headline.';
  }
  return headline;
}

String _fallbackHeadline(RefreshRecommendBasis? basis) {
  return switch (basis) {
    RefreshRecommendBasis.measure => '측정 결과와 오늘 환경을 분석했어요.',
    RefreshRecommendBasis.weatherAndSchedule => '오늘 일정과 날씨를 분석했어요.',
    RefreshRecommendBasis.weatherOnly || null => '오늘의 환경을 분석했어요.',
  };
}

/// 맞춤 리프레시 카드 하단 키워드 — 케어 · 요일 · 시간 · 소요.
List<String> buildRecommendMetaTags({
  required String careName,
  required int durationMinutes,
  DateTime? scheduleAt,
}) {
  const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  final at = scheduleAt ?? DateTime.now();
  final weekday = '${weekdayLabels[at.weekday - 1]}요일';
  final period = at.hour < 12 ? '오전' : '오후';
  final hour12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
  final timeLabel = at.minute == 0
      ? '$period $hour12시'
      : '$period $hour12시 ${at.minute}분';

  return [careName, weekday, timeLabel, '$durationMinutes분 소요'];
}
