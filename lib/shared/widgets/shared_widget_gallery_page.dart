import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_badge.dart';
import 'app_battery_status.dart';
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
import 'feature_placeholder_page.dart';
import 'feature_sub_page_scaffold.dart';

/// Medium Phone (360×800) 기준 위젯 미리보기 폭.
const double _phonePreviewWidth = 360;

class SharedWidgetGalleryPage extends StatefulWidget {
  const SharedWidgetGalleryPage({super.key});

  @override
  State<SharedWidgetGalleryPage> createState() =>
      _SharedWidgetGalleryPageState();
}

class _SharedWidgetGalleryPageState extends State<SharedWidgetGalleryPage> {
  int _segmentedIndex = 0;
  int _segmented2Index = 0;
  int _chipIndex = 0;
  int _weekIndex = 2;
  int _dayIndex = 2;
  int _pageIndicatorIndex = 0;
  int _boxMiniIndex = 0;
  bool _checkbox = true;
  bool _toggle = true;
  bool _listCheckSelected = true;
  String _radioGroup = 'a';
  String _listRadioGroup = 'a';
  final _emptyFieldController = TextEditingController();
  final _fieldController = TextEditingController(text: 'text');
  final _searchHeaderController = TextEditingController();
  final _searchFieldController = TextEditingController();

  static const _widgetFiles = <(String, String)>[
    ('AppBadge', 'app_badge.dart'),
    ('AppBatteryStatus', 'app_battery_status.dart'),
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
    ('FeaturePlaceholderPage', 'feature_placeholder_page.dart'),
    ('FeatureSubPageScaffold', 'feature_sub_page_scaffold.dart'),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _phonePreviewWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            clipBehavior: Clip.none,
            children: _buildGallerySections(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGallerySections() {
    return [
      _phoneFrameLabel('Medium Phone · 360dp · Figma Component2'),
      _groupTitle('Badge & Cards'),
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
      _groupTitle('Device Status'),
      _section(
        'AppBatteryStatus',
        'icon_battery_24 · state 0/10/30/40/50/60/80/100 + %',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final sample in const [5, 20, 50, 85]) ...[
              AppBatteryStatus(percent: sample),
              if (sample != 85) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
      _groupTitle('Bottom CTA'),
      _section(
        'AppBottomButtonBar',
        'button_bottom · 1 or 2 buttons',
        _bottomBarPreview(
          Column(
            children: [
              AppBottomButtonBar(primaryLabel: '시작하기', onPrimaryPressed: () {}),
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
      ),
      _groupTitle('Button'),
      _section(
        'AppCapsuleButton',
        'Button_Capsule_Text · Gradient #5D70FF → #8694FF',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppCapsuleButton(
                label: 'Icon Left',
                icon: Icons.add,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: AppCapsuleButton(
                label: 'Icon Right',
                icon: Icons.arrow_forward,
                iconPosition: AppCapsuleButtonIconPosition.right,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppCapsuleButton(label: 'Disabled', onPressed: null),
            ),
          ],
        ),
      ),
      _section(
        'AppCapsuleIconButton',
        'Button_Capsule_IconOnly · 24×24',
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppCapsuleIconButton(onPressed: () {}),
            AppCapsuleIconButton(
              onPressed: () {},
              variant: AppCapsuleIconButtonVariant.secondary,
            ),
            const AppCapsuleIconButton(onPressed: null),
          ],
        ),
      ),
      _section(
        'AppBoxMiniButton',
        'Button_select_ · 42×32',
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < 3; i++)
              AppBoxMiniButton(
                label: '${i + 1}',
                selected: _boxMiniIndex == i,
                onPressed: () => setState(() => _boxMiniIndex = i),
              ),
          ],
        ),
      ),
      _section(
        'AppTextLinkButton',
        'Button_text · #8B939E',
        AppTextLinkButton(label: '텍스트 링크', onPressed: () {}),
      ),
      _groupTitle('Indicator'),
      _section(
        'AppPageIndicator',
        'indicator · active #4E5561',
        Center(
          child: AppPageIndicator(
            count: 5,
            selectedIndex: _pageIndicatorIndex,
            onDotTap: (i) => setState(() => _pageIndicatorIndex = i),
          ),
        ),
      ),
      _groupTitle('Common'),
      _section(
        'AppBoxButton',
        'Button_Box · Active #5D70FF · Line #EFF1F4',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            AppBoxButton(
              label: 'Medium',
              onPressed: () {},
              size: AppBoxButtonSize.medium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppBoxButton(
              label: 'Small',
              onPressed: () {},
              size: AppBoxButtonSize.small,
            ),
          ],
        ),
      ),
      _section(
        'Controls',
        'Button_Radio / Check Box / Toggle',
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppCheckbox(
              value: _checkbox,
              onChanged: (v) => setState(() => _checkbox = v),
            ),
            AppRadio<String>(
              value: 'a',
              groupValue: _radioGroup,
              onChanged: (v) => setState(() => _radioGroup = v!),
            ),
            AppRadio<String>(
              value: 'b',
              groupValue: _radioGroup,
              onChanged: (v) => setState(() => _radioGroup = v!),
            ),
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
        'Text Field · Background #F7F7F7',
        Column(
          children: [
            AppTextField(controller: _emptyFieldController, hintText: 'text'),
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
              variant: AppListItemVariant.icon,
              leadingIcon: Icons.star_outline,
              onTap: () {},
            ),
            AppListItem(
              title: 'Text',
              variant: AppListItemVariant.check,
              selected: _listCheckSelected,
              onTap: () => setState(() => _listCheckSelected = true),
            ),
            AppListItem(
              title: 'Text',
              variant: AppListItemVariant.radio,
              radioValue: 'a',
              radioGroupValue: _listRadioGroup,
              onRadioChanged: (v) =>
                  setState(() => _listRadioGroup = v! as String),
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
      _section(
        'AppSectionTitle',
        'Title #313842 · Subtitle #8B939E',
        const AppSectionTitle(title: '컨텐츠 타이틀 최대 2줄', subtitle: '서브 타이틀 최대 1줄'),
      ),
      _section(
        'AppTopHeader',
        'Legacy simple header',
        _previewFrame(_headerPreview(const AppTopHeader(title: 'LG ThinQ'))),
      ),
      _section(
        'AppCommonTopHeader',
        'Top_Header_Common · Game / Home / GNB / Search',
        _previewFrame(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerPreview(
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.game,
                  featureName: '기능명',
                  pageName: '페이지명',
                  onAlarm: () {},
                  onShare: () {},
                  onClose: () {},
                ),
              ),
              _headerPreview(
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.home,
                  title: 'LG ThinQ',
                  onSearch: () {},
                  onMenu: () {},
                ),
              ),
              _headerPreview(
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.gnb,
                  title: '타이틀',
                  onBack: () {},
                  onSettings: () {},
                  onClose: () {},
                ),
              ),
              _headerPreview(
                AppCommonTopHeader(
                  variant: AppCommonTopHeaderVariant.search,
                  searchController: _searchHeaderController,
                  onBack: () {},
                ),
              ),
            ],
          ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _variantLabel('None'),
            _previewFrame(
              _headerPreview(
                AppCalendarTopHeader(
                  variant: AppCalendarTopHeaderVariant.none,
                  monthValue: '2024.12',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _variantLabel('Weekly'),
            _previewFrame(
              _headerPreview(
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
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _variantLabel('Daily'),
            _previewFrame(
              _headerPreview(
                AppCalendarTopHeader(
                  variant: AppCalendarTopHeaderVariant.daily,
                  monthValue: '2024.12',
                  days: [
                    const AppCalendarDayCell(weekdayLabel: '금', dayLabel: '23'),
                    const AppCalendarDayCell(weekdayLabel: '토', dayLabel: '24'),
                    AppCalendarDayCell(
                      weekdayLabel: '오늘',
                      dayLabel: '25',
                      isSelected: _dayIndex == 2,
                    ),
                    const AppCalendarDayCell(weekdayLabel: '월', dayLabel: '26'),
                    const AppCalendarDayCell(weekdayLabel: '화', dayLabel: '27'),
                    const AppCalendarDayCell(weekdayLabel: '수', dayLabel: '28'),
                    const AppCalendarDayCell(weekdayLabel: '목', dayLabel: '29'),
                    const AppCalendarDayCell(weekdayLabel: '금', dayLabel: '30'),
                  ],
                  onDaySelected: (i) => setState(() => _dayIndex = i),
                ),
              ),
            ),
          ],
        ),
      ),
      _groupTitle('Tabs & Dialog'),
      _section(
        'AppSegmentedTabBar',
        'Tab_Segmented Tab · 3 pills / 2 pills',
        Column(
          children: [
            AppSegmentedTabBar(
              tabs: const ['Selected', 'Normal', 'Normal'],
              selectedIndex: _segmentedIndex,
              onChanged: (i) => setState(() => _segmentedIndex = i),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSegmentedTabBar(
              tabs: const ['Selected', 'Normal'],
              selectedIndex: _segmented2Index,
              onChanged: (i) => setState(() => _segmented2Index = i),
            ),
          ],
        ),
      ),
      _section(
        'AppChipTabBar',
        'Tab_Chip Tab · horizontal scroll',
        AppChipTabBar(
          tabs: const ['Selected', 'Normal', 'Normal', 'Normal', 'Normal'],
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
      _groupTitle('Layout'),
      _section(
        'FeaturePlaceholderPage',
        'MVP feature placeholder body · title + description + checklist',
        SizedBox(
          height: 300,
          child: FeaturePlaceholderPage(
            title: '디바이스 관리',
            description: '기기 연결, 필터 교체, 배터리 상태를 확인합니다.',
            items: const ['기기 연결 상태', '필터 잔량 확인', '배터리 잔량 확인'],
            footer: AppBoxButton(
              label: '설정 열기',
              onPressed: () {},
              size: AppBoxButtonSize.medium,
            ),
          ),
        ),
      ),
      _section(
        'FeatureSubPageScaffold',
        'AppTopHeader + FeaturePlaceholderPage · push sub-page shell',
        AppBoxButton(
          label: '전체 화면 미리보기',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (previewContext) => FeatureSubPageScaffold(
                  title: '디바이스 관리',
                  description: '홈 허브에서 진입하는 feature 서브 페이지 레이아웃입니다.',
                  items: const ['기기 연결 상태', '필터 잔량 확인', '배터리 잔량 확인'],
                  onBack: () => Navigator.of(previewContext).pop(),
                ),
              ),
            );
          },
          size: AppBoxButtonSize.medium,
        ),
      ),
      _groupTitle('Reference'),
      _section(
        'Widget file map',
        'lib/shared/widgets/',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in _widgetFiles)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.$1,
                      style: AppTextStyles.labelM.copyWith(
                        color: AppComponentColors.sectionTitle,
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
    ];
  }

  /// 갤러리 미리보기에서 SafeArea inset을 제거해 디자인 높이 그대로 표시.
  Widget _safeAreaPreview(
    Widget child, {
    bool removeTop = true,
    bool removeBottom = false,
  }) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: removeTop,
      removeBottom: removeBottom,
      child: child,
    );
  }

  Widget _headerPreview(PreferredSizeWidget header) {
    return _safeAreaPreview(
      SizedBox(
        width: double.infinity,
        height: header.preferredSize.height,
        child: header,
      ),
    );
  }

  Widget _bottomBarPreview(Widget child) {
    return _safeAreaPreview(child, removeTop: true, removeBottom: true);
  }

  Widget _previewFrame(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _variantLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(color: AppColors.gray500),
      ),
    );
  }

  Widget _phoneFrameLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelS.copyWith(color: AppColors.gray0),
          ),
        ),
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
              SizedBox(width: double.infinity, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
