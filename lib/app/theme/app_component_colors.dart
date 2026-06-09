import 'package:flutter/material.dart';

/// Figma Design > Component 섹션에서 추출한 정확한 색상 값.
class AppComponentColors {
  const AppComponentColors._();

  // Button_Box
  static const buttonActiveBackground = Color(0xFF5D70FF);
  static const buttonActiveText = Color(0xFFFFFFFF);
  static const buttonLineBackground = Color(0xFFFFFFFF);
  static const buttonLineBorder = Color(0xFFEFF1F4);
  static const buttonLineText = Color(0xFF171B21);
  static const buttonTextBackground = Color(0xFFFFFFFF);
  static const buttonTextText = Color(0xFF323EA6);
  static const buttonDisabledBackground = Color(0xFFE6E9ED);
  static const buttonDisabledText = Color(0xFF5D6674);

  // Button_Capsule
  static const capsuleGradientStart = Color(0xFF5D70FF);
  static const capsuleGradientEnd = Color(0xFF8694FF);
  static const capsuleActiveText = Color(0xFFFFFFFF);
  static const capsuleDisabledBackground = Color(0xFFE6E9ED);
  static const capsuleDisabledText = Color(0xFF5D6674);

  static const capsuleGradient = LinearGradient(
    begin: Alignment(-0.2, 0.9),
    end: Alignment(0.8, 0.1),
    colors: [capsuleGradientStart, capsuleGradientEnd],
  );

  // Button_Radio
  static const radioOffFill = Color(0xFFB3BAC4);
  static const radioOnFill = Color(0xFF323EA6);

  // Button_Check Box
  static const checkboxOffBackground = Color(0xFFF7F7F7);
  static const checkboxOffBorder = Color(0xFFB3BAC4);
  static const checkboxOnFill = Color(0xFF8B939E);
  static const checkboxOnCheck = Color(0xFFFFFFFF);

  // Button_Toggle
  static const toggleThumb = Color(0xFFFFFFFF);
  static const toggleTrackOn = Color(0xFF5D70FF);
  static const toggleTrackOff = Color(0xFFDADEE3);

  // Text Field
  static const fieldBackground = Color(0xFFF7F7F7);
  static const fieldPlaceholder = Color(0xFF8B939E);
  static const fieldText = Color(0xFF171B21);
  static const fieldClearBackground = Color(0xFFD7D7D7);
  static const fieldClearIcon = Color(0xFFFFFFFF);

  // List_Common
  static const listTitle = Color(0xFF000000);
  static const listCaption = Color(0xFF8B939E);
  static const listRightLabel = Color(0xFF171B21);
  static const listSubText = Color(0xFF8B939E);
  static const listChevron = Color(0xFF4E5561);

  // Tab_Segmented
  static const segmentedBackground = Color(0xFFE6E9ED);
  static const segmentedBorder = Color(0xFFDADEE3);
  static const segmentedSelectedBackground = Color(0xFFFFFFFF);
  static const segmentedSelectedText = Color(0xFF313842);
  static const segmentedNormalText = Color(0xFF8B939E);

  // Tab_Chip
  static const chipSelectedBackground = Color(0xFF052C66);
  static const chipSelectedText = Color(0xFFFFFFFF);
  static const chipNormalBackground = Color(0xFFF5F7FA);
  static const chipNormalText = Color(0xFFB3BAC4);

  // Overlay_Popup
  static const dialogBackground = Color(0xFFFFFFFF);
  static const dialogText = Color(0xFF171B21);

  // Top_Header
  static const headerBackground = Color(0xFFFFFFFF);
  static const headerTitle = Color(0xFF313842);
  static const headerGameBorder = Color(0xFFF5F7FA);
  static const headerSubtitle = Color(0xFF8B939E);

  // Text Field_Search
  static const searchFieldBackground = Color(0xFFF5F7FA);

  // Top_Header_Calendar / Item/Calendar
  static const calendarPrimaryText = Color(0xFF222222);
  static const calendarAccent = Color(0xFFE11956);

  // List_Common_No Chevron info icon
  static const listInfoIcon = Color(0xFF4E5561);

  // Title
  static const sectionTitle = Color(0xFF313842);
  static const sectionSubtitle = Color(0xFF8B939E);

  // badge_small
  static const badgeSmallGrayBackground = Color(0xFFE6E9ED);
  static const badgeSmallGrayText = Color(0xFF5D6674);
  static const badgeSmallGrayFilledBackground = Color(0xFF5D6674);
  static const badgeSmallGrayFilledText = Color(0xFFEFF1F4);
  static const badgeSmallPrimaryBackground = Color(0xFFEBEDFF);
  static const badgeSmallPrimaryText = Color(0xFF323EA6);
  static const badgeSmallPrimaryFilledBackground = Color(0xFF323EA6);
  static const badgeSmallPrimaryFilledText = Color(0xFFF5F6FF);
  static const badgeSmallPrimaryLightBackground = Color(0xFFF5F6FF);
  static const badgeSmallPrimaryLightText = Color(0xFF323EA6);
  static const badgeSmallLowBackground = Color(0xFFE2EDFC);
  static const badgeSmallLowText = Color(0xFF0B4596);
  static const badgeSmallLowFilledBackground = Color(0xFF135FCD);
  static const badgeSmallLowFilledText = Color(0xFFEFF6FF);
  static const badgeSmallMediumBackground = Color(0xFFD9F6E9);
  static const badgeSmallMediumText = Color(0xFF075445);
  static const badgeSmallMediumFilledBackground = Color(0xFF00745F);
  static const badgeSmallMediumFilledText = Color(0xFFEDFAF6);
  static const badgeSmallHighBackground = Color(0xFFFFE8DB);
  static const badgeSmallHighText = Color(0xFFFF5700);
  static const badgeSmallHighFilledBackground = Color(0xFFFF6600);
  static const badgeSmallHighFilledText = Color(0xFFFFF2EC);
  static const badgeSmallVeryHighBackground = Color(0xFFFDE7E7);
  static const badgeSmallVeryHighText = Color(0xFF921708);
  static const badgeSmallVeryHighFilledBackground = Color(0xFFCA1D13);
  static const badgeSmallVeryHighFilledText = Color(0xFFFDF0F0);

  // badge_large
  static const badgeLargeRefreshNotNeeded = Color(0xFF217CF9);
  static const badgeLargeRefreshSelected = Color(0xFF079171);
  static const badgeLargeFocusedRecommend = Color(0xFFFF6600);
  static const badgeLargeFocusedRequired = Color(0xFFFA342C);
  static const badgeLargeRefreshRecommend = Color(0xFFFBDC65);
  static const badgeLargeRefreshRecommendText = Color(0xFF2A3038);
  static const badgeLargeText = Color(0xFFFFFFFF);

  // Button_Box_mini
  static const boxMiniOffBackground = Color(0xFFEFF1F4);
  static const boxMiniOffText = Color(0xFF8B939E);
  static const boxMiniOnBackground = Color(0xFFF5F6FF);
  static const boxMiniOnBorder = Color(0xFF5D70FF);
  static const boxMiniOnText = Color(0xFF323EA6);

  // Button_Capsule_IconOnly (disabled / secondary)
  static const capsuleIconOnlySecondary = Color(0xFF7E8DFF);

  // Button_text
  static const textLinkButton = Color(0xFF8B939E);

  // card_refresh
  static const refreshCardDefaultBackground = Color(0xFFF5F6FF);
  static const refreshCardDefaultBorder = Color(0xFFEBEDFF);
  static const refreshCardCompactBackground = Color(0xFFFFFFFF);
  static const refreshCardCompactBorder = Color(0xFFEFF1F4);
  static const refreshCardTitle = Color(0xFF052C66);
  static const refreshCardBody = Color(0xFF4E5561);
  static const refreshCardCaption = Color(0xFF8B939E);

  // card_recommend
  static const recommendCardGradientStart = Color(0xFFF5F6FF);
  static const recommendCardGradientEnd = Color(0xFFEBEDFF);
  static const recommendCardBorderStart = Color(0xFF8694FF);
  static const recommendCardBorderEnd = Color(0xFFB8B8FF);
  static const recommendCardText = Color(0xFF171B21);

  // card_result
  static const resultCardBackground = Color(0xFFFFFFFF);
  static const resultCardTitle = Color(0xFF171B21);
  static const resultCardTagText = Color(0xFF5D6674);
  static const resultCardTagDot = Color(0xFFFF6600);

  // indicator
  static const indicatorActive = Color(0xFF4E5561);
  static const indicatorInactive = Color(0xFFD9D9D9);

  // button_bottom
  static const bottomBarBackground = Color(0xFFFFFFFF);
}
