import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/hair_profile_options.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../widgets/measure_hair_profile_radio_tile.dart';
import '../widgets/measure_prepare_bottom_bar.dart';
import '../widgets/measure_prepare_instruction.dart';
import '../widgets/measure_step_indicator.dart';

/// Figma 1224-23687 — 진단 전 모발 유형 선택.
class MeasureHairProfilePage extends StatefulWidget {
  const MeasureHairProfilePage({super.key});

  @override
  State<MeasureHairProfilePage> createState() => _MeasureHairProfilePageState();
}

class _MeasureHairProfilePageState extends State<MeasureHairProfilePage> {
  static const double _horizontalPadding = 15;
  static const double _gridGap = 6;

  final _userProfileService = const UserProfileService();

  String? _selectedHairType;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isFormValid => _selectedHairType != null;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await _userProfileService.fetchHairProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedHairType = profile?.hairType;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onHairTypeSelected(String hairType) async {
    if (_selectedHairType == hairType) {
      return;
    }

    setState(() => _selectedHairType = hairType);

    try {
      await _userProfileService.saveHairProfile(hairType: hairType);
    } on UserProfileServiceException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _onNextPressed() async {
    if (!_isFormValid || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _userProfileService.saveHairProfile(hairType: _selectedHairType!);

      if (!mounted) {
        return;
      }

      context.pushMeasurePrepare();
    } on UserProfileServiceException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildHairTypeGrid() {
    final options = HairProfileOptions.hairTypes;
    final rowCount = (options.length / 2).ceil();

    return Column(
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) const SizedBox(height: _gridGap),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: _gridGap),
                Expanded(
                  child: row * 2 + col < options.length
                      ? MeasureHairProfileRadioTile(
                          label: options[row * 2 + col],
                          selected: _selectedHairType == options[row * 2 + col],
                          onTap: () =>
                              _onHairTypeSelected(options[row * 2 + col]),
                        )
                      : const SizedBox(
                          height: MeasureHairProfileRadioTile.tileHeight,
                        ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 상태 진단',
        onBack: () => context.pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const MeasureStepIndicator(
                  currentStep: MeasureIntroStepIndicator.hairProfileStepIndex,
                  totalSteps: MeasureIntroStepIndicator.totalSteps,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const MeasurePrepareInstruction(
                          title: '모발 유형을 선택해주세요.',
                          subtitle: '가장 가까운 모발 유형을 선택해주세요.',
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildHairTypeGrid(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                MeasurePrepareBottomBar(
                  label: _isSaving ? '저장 중...' : '다음',
                  enabled: _isFormValid && !_isSaving,
                  onPressed: _onNextPressed,
                ),
              ],
            ),
    );
  }
}
