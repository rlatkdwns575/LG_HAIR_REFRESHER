import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_paths.dart';
import '../../data/api/auth_api.dart';
import '../../data/model/auth_failure.dart';
import '../../data/model/sign_up_draft.dart';
import '../widgets/auth_screen_styles.dart';
import '../widgets/auth_screen_widgets.dart';

/// 회원가입 2단계 — 이름·나이·성별 입력.
class SignUpStepTwoScreen extends StatefulWidget {
  const SignUpStepTwoScreen({required this.draft, super.key});

  final SignUpDraft draft;

  @override
  State<SignUpStepTwoScreen> createState() => _SignUpStepTwoScreenState();
}

class _SignUpStepTwoScreenState extends State<SignUpStepTwoScreen> {
  static const _minAge = 14;
  static const _maxAge = 80;
  static const _defaultAge = 24;

  final AuthApi _authApi = const AuthApi();
  final TextEditingController _nameController = TextEditingController();

  int? _selectedAge;
  String? _selectedGender;
  bool _isSubmitting = false;

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedAge != null &&
      _selectedGender != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  void _showAgePicker() {
    int tempAge = _selectedAge ?? _defaultAge;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나이 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AuthScreenStyles.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedAge = tempAge);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AuthScreenStyles.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 260,
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(
                    initialItem: tempAge - _minAge,
                  ),
                  onSelectedItemChanged: (index) {
                    tempAge = _minAge + index;
                  },
                  children: List.generate(_maxAge - _minAge + 1, (index) {
                    final age = _minAge + index;
                    return Center(
                      child: Text(
                        '$age세',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuthScreenStyles.textDark,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSignUpComplete() async {
    if (!_isFormValid || _isSubmitting) {
      return;
    }

    final signUpData = {
      'email': widget.draft.email,
      'password': widget.draft.password,
      'name': _nameController.text.trim(),
      'age': _selectedAge,
      'gender': _selectedGender,
    };

    if (kDebugMode) {
      debugPrint(signUpData.toString());
    }

    setState(() => _isSubmitting = true);

    try {
      await _authApi.signUpWithProfile(
        email: widget.draft.email,
        password: widget.draft.password,
        name: _nameController.text.trim(),
        age: _selectedAge!,
        gender: _selectedGender!,
      );

      if (_authApi.hasSession) {
        await _authApi.signOut();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.go(AppRoutePaths.login);
    } on AuthFailure catch (error) {
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('회원가입에 실패했습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildAgePickerField() {
    final hasValue = _selectedAge != null;

    return GestureDetector(
      onTap: _showAgePicker,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AuthScreenStyles.fieldFill,
          borderRadius: BorderRadius.circular(AuthScreenStyles.fieldRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasValue ? '$_selectedAge세' : '나이를 선택해주세요',
              style: TextStyle(
                fontSize: 14,
                color: hasValue
                    ? AuthScreenStyles.textDark
                    : AuthScreenStyles.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AuthScreenStyles.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String label) {
    final selected = _selectedGender == label;

    return Expanded(
      child: Material(
        color: selected
            ? AuthScreenStyles.genderSelectedBg
            : AuthScreenStyles.fieldFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthScreenStyles.fieldRadius),
          side: BorderSide(
            color: selected
                ? AuthScreenStyles.genderSelectedBorder
                : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _selectedGender = label),
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AuthScreenStyles.primaryBlue
                      : AuthScreenStyles.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuthScreenStyles.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthCloseHeader(title: '회원가입'),
              const SizedBox(height: 12),
              const AuthSignupProgressLine(step: 2),
              const SizedBox(height: 36),
              buildAuthFieldLabel('이름(닉네임)을 입력해주세요.', fontSize: 18),
              const SizedBox(height: 12),
              buildAuthTextField(
                controller: _nameController,
                hintText: '이름 입력 (20자 이내)',
                maxLength: 20,
              ),
              const SizedBox(height: 32),
              buildAuthFieldLabel('나이를 입력해주세요.', fontSize: 18),
              const SizedBox(height: 12),
              _buildAgePickerField(),
              const SizedBox(height: 32),
              buildAuthFieldLabel('성별을 선택해주세요.', fontSize: 18),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildGenderButton('남성'),
                  const SizedBox(width: 12),
                  _buildGenderButton('여성'),
                ],
              ),
              const Spacer(),
              AuthPrimaryButton(
                label: _isSubmitting ? '처리 중...' : '확인',
                enabled: _isFormValid && !_isSubmitting,
                onPressed: _handleSignUpComplete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
