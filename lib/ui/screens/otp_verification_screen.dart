import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../services/auth_service.dart';

/// Screen 6 — OTP Verification
///
/// 4-digit OTP input with custom number pad, countdown timer,
/// resend code functionality, and "Verify & Proceed" button.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _otp = ['', '', '', ''];
  int _currentIndex = 0;
  int _countdown = 45;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  // Received from sign-in screen
  String _phone = '';
  String _countryCode = '+91';
  String _fullPhone = '';

  late final AnimationController _fadeController;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _boxesOpacity;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _keypadOpacity;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _boxesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _keypadOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  void _startCountdown() {
    _countdown = 45;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phone = args['phone'] ?? '';
      _countryCode = args['country_code'] ?? '+91';
      _fullPhone = args['full_phone'] ?? '$_countryCode$_phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Verification',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, _) {
          return Column(
            children: [
              // ── Upper section (scrollable) ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // ── Title ─────────────────────────────────────────
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: _buildTitle(),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // ── OTP Boxes ─────────────────────────────────────
                      Opacity(
                        opacity: _boxesOpacity.value,
                        child: _buildOtpBoxes(),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Resend timer ──────────────────────────────────
                      Opacity(
                        opacity: _boxesOpacity.value,
                        child: _buildResendTimer(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Verify button ─────────────────────────────────
                      Opacity(
                        opacity: _buttonOpacity.value,
                        child: _buildVerifyButton(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Number pad ────────────────────────────────────────────
              Opacity(
                opacity: _keypadOpacity.value,
                child: _buildNumberPad(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Verify Your Number',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Code sent to '),
              TextSpan(
                text: _fullPhone.isNotEmpty ? _fullPhone : '+1 •••• ••• 45',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentIndex;
        final isFilled = _otp[index].isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 68,
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.primarySurface
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : isFilled
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.borderLight,
              width: isActive ? 2 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                _otp[index],
                key: ValueKey(_otp[index] + index.toString()),
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendTimer() {
    if (_canResend) {
      return GestureDetector(
        onTap: _resendCode,
        child: Text(
          'Resend Code',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    final timeStr =
        '$minutes:${seconds.toString().padLeft(2, '0')}';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Resend Code in  ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(
            text: timeStr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    final bool isComplete = _otp.every((d) => d.isNotEmpty);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: AppSpacing.buttonHeightLg + 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isComplete
              ? [AppColors.primary, const Color(0xFF4B8AFF)]
              : [
                  AppColors.primary.withValues(alpha: 0.4),
                  const Color(0xFF4B8AFF).withValues(alpha: 0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: isComplete && !_isVerifying ? _verify : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Center(
            child: _isVerifying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Verify & Proceed',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: 1 2 3
          _buildKeyRow(['1', '2', '3']),
          const SizedBox(height: AppSpacing.md),
          // Row 2: 4 5 6
          _buildKeyRow(['4', '5', '6']),
          const SizedBox(height: AppSpacing.md),
          // Row 3: 7 8 9
          _buildKeyRow(['7', '8', '9']),
          const SizedBox(height: AppSpacing.md),
          // Row 4: empty 0 backspace
          Row(
            children: [
              Expanded(child: Container()), // Empty space
              Expanded(
                child: _NumberKey(
                  label: '0',
                  onTap: () => _onKeyTap('0'),
                ),
              ),
              Expanded(
                child: _BackspaceKey(
                  onTap: _onBackspace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      children: keys
          .map(
            (key) => Expanded(
              child: _NumberKey(
                label: key,
                onTap: () => _onKeyTap(key),
              ),
            ),
          )
          .toList(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═════════════════════════════════════════════════════════════════════════

  void _onKeyTap(String digit) {
    if (_currentIndex >= 4) return;
    setState(() {
      _otp[_currentIndex] = digit;
      if (_currentIndex < 3) {
        _currentIndex++;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_otp[_currentIndex].isNotEmpty) {
        _otp[_currentIndex] = '';
      } else if (_currentIndex > 0) {
        _currentIndex--;
        _otp[_currentIndex] = '';
      }
    });
  }

  void _resendCode() async {
    _startCountdown();
    setState(() {
      _otp.fillRange(0, 4, '');
      _currentIndex = 0;
    });

    // Resend OTP via API
    if (_phone.isNotEmpty) {
      await AuthService.sendOtp(phone: _phone, countryCode: _countryCode);
    }
  }

  void _verify() async {
    setState(() => _isVerifying = true);

    final otpCode = _otp.join();
    final result = await AuthService.verifyOtp(
      phone: _phone,
      otp: otpCode,
      countryCode: _countryCode,
    );

    if (mounted) {
      setState(() => _isVerifying = false);

      if (result['success'] == true) {
        // Check if new user → go to ID verification, else home
        if (result['is_new_user'] == true) {
          Navigator.of(context).pushReplacementNamed('/id-verification');
        } else {
          final user = result['user'];
          if (user != null && user['kyc_status'] == 'verified') {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/id-verification');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Invalid OTP')),
        );
        // Clear OTP fields on failure
        setState(() {
          _otp.fillRange(0, 4, '');
          _currentIndex = 0;
        });
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NUMBER PAD KEYS
// ═══════════════════════════════════════════════════════════════════════════

class _NumberKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumberKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  final VoidCallback onTap;

  const _BackspaceKey({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.backspace_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
