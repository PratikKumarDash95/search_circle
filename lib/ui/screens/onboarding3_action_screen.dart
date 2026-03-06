import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/onboarding_widgets.dart';
import '../widgets/secure_camera_illustration.dart';

/// Screen 4 — Onboarding 3: Action
///
/// Final onboarding page: "Record & report safely with one tap"
/// Shows secure camera illustration, page dots (3/3 active),
/// "Get Started" button (replaces "Next"), back arrow, and "Skip" text.
class Onboarding3ActionScreen extends StatefulWidget {
  const Onboarding3ActionScreen({super.key});

  @override
  State<Onboarding3ActionScreen> createState() =>
      _Onboarding3ActionScreenState();
}

class _Onboarding3ActionScreenState extends State<Onboarding3ActionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _illustrationOpacity;
  late final Animation<double> _illustrationSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _illustrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _illustrationSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFF2F5FC),
              Color(0xFFEEF1F8),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Column(
                children: [
                  // ── Top bar with back + skip ──────────────────────────
                  _buildTopBar(),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Camera Illustration ───────────────────────────────
                  Expanded(
                    flex: 5,
                    child: Opacity(
                      opacity: _illustrationOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _illustrationSlide.value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          child: const SecureCameraIllustration(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Title + Subtitle ──────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: _buildTextContent(),
                    ),
                  ),

                  // ── Page Indicator Dots ───────────────────────────────
                  Opacity(
                    opacity: _dotsOpacity.value,
                    child: const OnboardingPageIndicator(
                      currentPage: 2,
                      pageCount: 3,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Get Started Button ────────────────────────────────
                  Opacity(
                    opacity: _buttonOpacity.value,
                    child: _buildGetStartedButton(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Back button ────────────────────────────────────────────────
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),

          // ── Skip button ────────────────────────────────────────────────
          TextButton(
            onPressed: _skipToSignIn,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.buttonMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Record & report\n',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'safely with one tap',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Secure, direct-to-police upload feature\nensures your evidence is saved and sent\nimmediately when you need help.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonHeightLg + 4,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary,
              Color(0xFF4B8AFF),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: _goToSignIn,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: Text(
                'Get Started',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  void _skipToSignIn() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }
}
