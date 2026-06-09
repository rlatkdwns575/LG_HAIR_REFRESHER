import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_badge.dart';
import 'app_bottom_button_bar.dart';
import 'app_box_button.dart';
import 'app_box_mini_button.dart';
import 'app_calendar_day_strip.dart';
import 'app_calendar_item.dart';
import 'app_calendar_top_header.dart';
import 'app_calendar_week_strip.dart';
import 'app_capsule_button.dart';
import 'app_capsule_icon_button.dart';
import 'app_checkbox.dart';
import 'app_chip_tab_bar.dart';
import 'app_common_top_header.dart';
import 'app_confirm_dialog.dart';
import 'app_list_item.dart';
import 'app_page_indicator.dart';
import 'app_radio.dart';
import 'app_recommend_card.dart';
import 'app_refresh_card.dart';
import 'app_result_card.dart';
import 'app_search_text_field.dart';
import 'app_section_title.dart';
import 'app_segmented_tab_bar.dart';
import 'app_text_field.dart';
import 'app_text_link_button.dart';
import 'app_toggle.dart';
import 'app_top_header.dart';

class SharedWidgetGalleryPage extends StatefulWidget {
  const SharedWidgetGalleryPage({super.key});

  @override
  State<SharedWidgetGalleryPage> createState() =>
      _SharedWidgetGalleryPageState();
}

class _SharedWidgetGalleryPageState extends State<SharedWidgetGalleryPage> {
  int _segmentedIndex = 0;
  int _chipIndex = 0;
  int _weekIndex = 2;
  int _dayIndex = 2;
  int _pageIndicatorIndex = 0;
  int _boxMiniIndex = 0;
  bool _checkbox = true;
  bool _toggle = true;
  String _radioGroup = 'a';
  final _emptyFieldController = TextEditingController();
  final _fieldController = TextEditingController(text: 'text');
  final _searchHeaderController = TextEditingController();
  final _searchFieldController = TextEditingController();

  static const _widgetFiles = <(String, String)>[
    ('AppBadge', 'app_badge.dart'),
    ('AppBoxButton', 'app_box_button.dart'),
    ('AppBoxMiniButton', 'app_box_mini_button.dart'),
    ('AppBottomButtonBar', 'app_bottom_button_bar.dart'),
    ('AppCapsuleButton', 'app_capsule_button.dart'),
    ('AppCapsuleIconButton', 'app_capsule_icon_button.dart'),
    ('AppCheckbox', 'app_checkbox.dart'),
    ('AppRadio', 'app_radio.dart'),
    ('AppToggle', 'app_toggle.dart'),
    ('AppTextField', 'app_text_field.dart'),
    ('AppSearchTextField', 'app_search_text_field.dart'),
    ('AppListItem', 'app_list_item.dart'),
    ('AppSectionTitle', 'app_section_title.dart'),
    ('AppTopHeader', 'app_top_header.dart'),
    ('AppCommonTopHeader', 'app_common_top_header.dart'),
    ('AppCalendarItem', 'app_calendar_item.dart'),
    ('AppCalendarWeekStrip', 'app_calendar_week_strip.dart'),
    ('AppCalendarDayStrip', 'app_calendar_day_strip.dart'),
    ('AppCalendarTopHeader', 'app_calendar_top_header.dart'),
    ('AppSegmentedTabBar', 'app_segmented_tab_bar.dart'),
    ('AppChipTabBar', 'app_chip_tab_bar.dart'),
    ('AppConfirmDialog', 'app_confirm_dialog.dart'),
    ('AppPageIndicator', 'app_page_indicator.dart'),
    ('AppRecommendCard', 'app_recommend_card.dart'),
    ('AppRefreshCard', 'app_refresh_card.dart'),
    ('AppResultCard', 'app_result_card.dart'),
    ('AppTextLinkButton', 'app_text_link_button.dart'),
  ];

  @override
  void dispose() {
    _emptyFieldController.dispose();
    _fieldController.dispose();
    _searchHeaderController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Shared Widgets Gallery'),
        backgroundColor: AppComponentColors.headerBackground,
        foregroundColor: AppComponentColors.headerTitle,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _groupTitle('Buttons & Inputs'),
          _section(
            'AppBoxButton',
            'Active #5D70FF · Line border #EFF1F4 · Text #323EA6',
            Column(
              children: [
                AppBoxButton(label: '버튼명', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppBoxButton(
                  label: '버튼명',
                  onPressed: () {},
                  variant: AppBoxButtonVariant.line,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppBoxButton(
                  label: '버튼명',
                  onPressed: () {},
                  variant: AppBoxButtonVariant.text,
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppBoxButton(
                  label: '버튼명',
                  onPressed: null,
                  variant: AppBoxButtonVariant.disabled,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppBoxButton(
                      label: 'Medium',
                      onPressed: () {},
                      size: AppBoxButtonSize.medium,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBoxButton(
                      label: 'Small',
                      onPressed: () {},
                      size: AppBoxButtonSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'AppCapsuleButton',
            'Gradient #5D70FF → #8694FF',
            Row(
              children: [
                AppCapsuleButton(
                  label: 'Text',
                  icon: Icons.add,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.sm),
                const AppCapsuleButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
          _section(
            'AppCapsuleIconButton',
            'Button_Capsule_IconOnly · 24×24',
            Row(
              children: [
                AppCapsuleIconButton(onPressed: () {}),
                const SizedBox(width: AppSpacing.sm),
                AppCapsuleIconButton(
                  onPressed: () {},
                  variant: AppCapsuleIconButtonVariant.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                const AppCapsuleIconButton(onPressed: null),
              ],
            ),
          ),
          _section(
            'AppBoxMiniButton',
            'Button_Box_mini · 42×32',
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
                    child: AppBoxMiniButton(
                      label: '${i + 1}',
                      selected: _boxMiniIndex == i,
                      onPressed: () => setState(() => _boxMiniIndex = i),
                    ),
                  ),
              ],
            ),
          ),
          _section(
            'AppTextLinkButton',
            'Button_text · #8B939E',
            AppTextLinkButton(label: '텍스트 링크', onPressed: () {}),
          ),
          _section(
            'Controls',
            'Radio #B3BAC4/#323EA6 · Checkbox #8B939E · Toggle #5D70FF',
            Row(
              children: [
                AppCheckbox(
                  value: _checkbox,
                  onChanged: (v) => setState(() => _checkbox = v),
                ),
                const SizedBox(width: AppSpacing.md),
                AppRadio<String>(
                  value: 'a',
                  groupValue: _radioGroup,
                  onChanged: (v) => setState(() => _radioGroup = v!),
                ),
                const SizedBox(width: AppSpacing.xs),
                AppRadio<String>(
                  value: 'b',
                  groupValue: _radioGroup,
                  onChanged: (v) => setState(() => _radioGroup = v!),
                ),
                const SizedBox(width: AppSpacing.md),
                AppToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                  size: AppToggleSize.large,
                ),
              ],
            ),
          ),
          _section(
            'AppTextField',
            'Background #F7F7F7 · Placeholder #8B939E',
            Column(
              children: [
                AppTextField(
                  controller: _emptyFieldController,
                  hintText: 'text',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _fieldController,
                  state: AppTextFieldState.completed,
                  onClear: () => setState(() => _fieldController.clear()),
                ),
              ],
            ),
          ),
          _section(
            'AppSearchTextField',
            'Text Field_Search · Background #F5F7FA',
            AppSearchTextField(controller: _searchFieldController),
          ),
          _groupTitle('Lists'),
          _section(
            'AppListItem',
            'List_Common_* · Title #000000 · Caption #8B939E',
            Column(
              children: [
                AppListItem(title: 'Text', caption: 'Caption', onTap: () {}),
                AppListItem(
                  title: 'Text',
                  rightLabel: 'Label',
                  variant: AppListItemVariant.chevronWithRightLabel,
                  onTap: () {},
                ),
                AppListItem(
                  title: 'Text',
                  caption: 'Caption',
                  variant: AppListItemVariant.noChevron,
                  showInfoIcon: true,
                  onTap: () {},
                ),
                AppListItem(
                  title: 'Text',
                  variant: AppListItemVariant.checkbox,
                  rightLabel: '(Sub Text)',
                  checked: _checkbox,
                  onChanged: (v) => setState(() => _checkbox = v),
                ),
                AppListItem(
                  title: 'Text',
                  variant: AppListItemVariant.toggle,
                  toggleValue: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
              ],
            ),
          ),
          _groupTitle('Headers · Common'),
          _section(
            'AppSectionTitle',
            'Title #313842 · Subtitle #8B939E',
            const AppSectionTitle(
              title: '컨텐츠 타이틀 최대 2줄',
              subtitle: '서브 타이틀 최대 1줄',
            ),
          ),
          _section(
            'AppTopHeader',
            'Legacy simple header',
            const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: AppTopHeader(title: 'LG ThinQ'),
            ),
          ),
          _section(
            'AppCommonTopHeader',
            'Top_Header_Common · Game / Home / GNB / Search',
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: AppCommonTopHeader(
                    variant: AppCommonTopHeaderVariant.game,
                    featureName: '기능명',
                    pageName: '페이지명',
                    onAlarm: () {},
                    onShare: () {},
                    onClose: () {},
                  ),
                ),
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.home,
                  title: 'LG ThinQ',
                  onSearch: () {},
                  onMenu: () {},
                ),
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.gnb,
                  title: '타이틀',
                  onBack: () {},
                  onSettings: () {},
                  onClose: () {},
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  child: AppCommonTopHeader(
                    variant: AppCommonTopHeaderVariant.search,
                    searchController: _searchHeaderController,
                    onBack: () {},
                  ),
                ),
              ],
            ),
          ),
          _groupTitle('Headers · Calendar'),
          _section(
            'AppCalendarItem',
            'Item/Calendar · #222222 · accent #E11956',
            AppCalendarItem(
              value: '2024.12',
              onPrevious: () {},
              onNext: () {},
              onToday: () {},
              onCalendar: () {},
            ),
          ),
          _section(
            'AppCalendarWeekStrip',
            'Top_Header_Calendar Weekly · Down',
            AppCalendarWeekStrip(
              weeks:
                  const [
                        AppCalendarWeekCell(label: '4월 1주차'),
                        AppCalendarWeekCell(label: '4월 2주차'),
                        AppCalendarWeekCell(label: '4월 3주차'),
                        AppCalendarWeekCell(label: '4월 4주차'),
                        AppCalendarWeekCell(label: '4월 5주차'),
                      ]
                      .asMap()
                      .entries
                      .map(
                        (e) => AppCalendarWeekCell(
                          label: e.value.label,
                          isSelected: e.key == _weekIndex,
                        ),
                      )
                      .toList(),
              onWeekSelected: (i) => setState(() => _weekIndex = i),
            ),
          ),
          _section(
            'AppCalendarDayStrip',
            'Top_Header_Calendar Daily · Down',
            AppCalendarDayStrip(
              days:
                  const [
                        AppCalendarDayCell(weekdayLabel: '금', dayLabel: '23'),
                        AppCalendarDayCell(weekdayLabel: '토', dayLabel: '24'),
                        AppCalendarDayCell(weekdayLabel: '오늘', dayLabel: '25'),
                        AppCalendarDayCell(weekdayLabel: '월', dayLabel: '26'),
                        AppCalendarDayCell(weekdayLabel: '화', dayLabel: '27'),
                        AppCalendarDayCell(weekdayLabel: '수', dayLabel: '28'),
                        AppCalendarDayCell(weekdayLabel: '목', dayLabel: '29'),
                        AppCalendarDayCell(weekdayLabel: '금', dayLabel: '30'),
                      ]
                      .asMap()
                      .entries
                      .map(
                        (e) => AppCalendarDayCell(
                          weekdayLabel: e.value.weekdayLabel,
                          dayLabel: e.value.dayLabel,
                          isSelected: e.key == _dayIndex,
                        ),
                      )
                      .toList(),
              onDaySelected: (i) => setState(() => _dayIndex = i),
            ),
          ),
          _section(
            'AppCalendarTopHeader',
            'Top_Header_Calendar · None / Weekly / Daily',
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: AppCalendarTopHeader(
                    variant: AppCalendarTopHeaderVariant.none,
                    monthValue: '2024.12',
                  ),
                ),
                AppCalendarTopHeader(
                  variant: AppCalendarTopHeaderVariant.weekly,
                  monthValue: '2024.12',
                  weeks: [
                    const AppCalendarWeekCell(label: '4월 1주차'),
                    const AppCalendarWeekCell(label: '4월 2주차'),
                    AppCalendarWeekCell(
                      label: '4월 3주차',
                      isSelected: _weekIndex == 2,
                    ),
                    const AppCalendarWeekCell(label: '4월 4주차'),
                    const AppCalendarWeekCell(label: '4월 5주차'),
                  ],
                  onWeekSelected: (i) => setState(() => _weekIndex = i),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  child: AppCalendarTopHeader(
                    variant: AppCalendarTopHeaderVariant.daily,
                    monthValue: '2024.12',
                    days: [
                      const AppCalendarDayCell(
                        weekdayLabel: '금',
                        dayLabel: '23',
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '토',
                        dayLabel: '24',
                      ),
                      AppCalendarDayCell(
                        weekdayLabel: '오늘',
                        dayLabel: '25',
                        isSelected: _dayIndex == 2,
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '월',
                        dayLabel: '26',
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '화',
                        dayLabel: '27',
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '수',
                        dayLabel: '28',
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '목',
                        dayLabel: '29',
                      ),
                      const AppCalendarDayCell(
                        weekdayLabel: '금',
                        dayLabel: '30',
                      ),
                    ],
                    onDaySelected: (i) => setState(() => _dayIndex = i),
                  ),
                ),
              ],
            ),
          ),
          _groupTitle('Badges & Cards'),
          _section(
            'AppBadge',
            'badge_small / badge_large',
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                const AppBadge(
                  label: 'Gray',
                  smallVariant: AppBadgeSmallVariant.gray,
                ),
                const AppBadge(
                  label: 'Primary',
                  smallVariant: AppBadgeSmallVariant.primary,
                ),
                const AppBadge(
                  label: 'High',
                  smallVariant: AppBadgeSmallVariant.high,
                  style: AppBadgeStyle.filled,
                ),
                const AppBadge(
                  label: '리프레시 불필요',
                  size: AppBadgeSize.large,
                  largeVariant: AppBadgeLargeVariant.refreshNotNeeded,
                ),
                const AppBadge(
                  label: '집중 리프레시 추천',
                  size: AppBadgeSize.large,
                  largeVariant: AppBadgeLargeVariant.focusedRecommend,
                ),
              ],
            ),
          ),
          _section(
            'AppRefreshCard',
            'card_refresh · default / compact / small',
            Column(
              children: [
                AppRefreshCard(
                  title: '모이스처 리프레시',
                  description: '건조한 모발에 수분을 공급하는 리프레시 모드입니다.',
                  captionItems: const ['약 5분', '중간 강도'],
                  badgeLabel: '추천',
                  badgeVariant: AppBadgeSmallVariant.primary,
                  onTrailingPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppRefreshCard(
                  title: '볼륨 리프레시',
                  description: '가벼운 볼륨 케어',
                  captionItems: const ['약 3분'],
                  badgeLabel: 'NEW',
                  badgeVariant: AppBadgeSmallVariant.primaryLight,
                  variant: AppRefreshCardVariant.compact,
                  onTrailingPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppRefreshCard(
                  title: '집중 케어',
                  description: '손상 모발 집중 케어',
                  variant: AppRefreshCardVariant.small,
                  onTrailingPressed: () {},
                ),
              ],
            ),
          ),
          _section(
            'AppRecommendCard',
            'card_recommend · gradient border',
            AppRecommendCard(
              message: '오늘은 모이스처 리프레시를 추천해요.',
              actionLabel: '리프레시 시작',
              onActionPressed: () {},
            ),
          ),
          _section(
            'AppResultCard',
            'card_result · default / withAction',
            Column(
              children: [
                AppResultCard(
                  title: '진단 결과',
                  tags: const [
                    AppResultCardTag(
                      label: '수분',
                      badgeLabel: '낮음',
                      badgeVariant: AppBadgeSmallVariant.low,
                    ),
                    AppResultCardTag(
                      label: '손상',
                      badgeLabel: '높음',
                      badgeVariant: AppBadgeSmallVariant.high,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppResultCard(
                  title: '리프레시 완료',
                  variant: AppResultCardVariant.withAction,
                  actionLabel: '기록 보러가기',
                  onActionPressed: () {},
                  tags: const [AppResultCardTag(label: '모이스처 리프레시')],
                ),
              ],
            ),
          ),
          _groupTitle('Layout'),
          _section(
            'AppPageIndicator',
            'indicator · active #4E5561',
            AppPageIndicator(
              count: 5,
              selectedIndex: _pageIndicatorIndex,
              onDotTap: (i) => setState(() => _pageIndicatorIndex = i),
            ),
          ),
          _section(
            'AppBottomButtonBar',
            'button_bottom · 1 or 2 buttons',
            Column(
              children: [
                AppBottomButtonBar(
                  primaryLabel: '시작하기',
                  onPrimaryPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppBottomButtonBar(
                  type: AppBottomButtonBarType.twoButtons,
                  primaryLabel: '확인',
                  onPrimaryPressed: () {},
                  secondaryLabel: '취소',
                  onSecondaryPressed: () {},
                ),
              ],
            ),
          ),
          _groupTitle('Tabs & Dialog'),
          _section(
            'AppSegmentedTabBar',
            'Bg #E6E9ED · Selected #FFFFFF/#313842',
            AppSegmentedTabBar(
              tabs: const ['Selected', 'Normal', 'Normal'],
              selectedIndex: _segmentedIndex,
              onChanged: (i) => setState(() => _segmentedIndex = i),
            ),
          ),
          _section(
            'AppChipTabBar',
            'Selected #052C66 · Normal #F5F7FA/#B3BAC4',
            AppChipTabBar(
              tabs: const ['Selected', 'Normal', 'Normal', 'Normal'],
              selectedIndex: _chipIndex,
              onChanged: (i) => setState(() => _chipIndex = i),
            ),
          ),
          _section(
            'AppConfirmDialog',
            'Overlay_Popup_Confirmation',
            AppBoxButton(
              label: '다이얼로그 열기',
              onPressed: () => AppConfirmDialog.show(
                context,
                title: '타이틀을 입력해주세요.',
                message: '텍스트가 한 줄일 경우 높이\n값은 두 줄로 유지합니다.',
              ),
              size: AppBoxButtonSize.medium,
            ),
          ),
          _section(
            'Widget file map',
            'lib/shared/widgets/',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in _widgetFiles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: Text(
                            entry.$1,
                            style: AppTextStyles.labelM.copyWith(
                              color: AppComponentColors.sectionTitle,
                            ),
                          ),
                        ),
                        Text(
                          entry.$2,
                          style: AppTextStyles.bodyXs.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.titleM.copyWith(
          color: AppComponentColors.sectionTitle,
        ),
      ),
    );
  }

  Widget _section(String title, String subtitle, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray0,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleS),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.gray500),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
