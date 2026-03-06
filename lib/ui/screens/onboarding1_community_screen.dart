import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/onboarding_widgets.dart';
import '../widgets/community_circle_illustration.dart';

/// Screen 2 — Onboarding 1: Community
///
/// First onboarding page: "Together we find missing people"
/// Shows community circle illustration, page dots (1/3 active),
/// "Next" button with arrow, and "Skip" text button.
class Onboarding1CommunityScreen extends StatefulWidget {
  const Onboarding1CommunityScreen({super.key});

  @override
  State<Onboarding1CommunityScreen> createState() =>
      _Onboarding1CommunityScreenState();
}

class _Onboarding1CommunityScreenState
    extends State<Onboarding1CommunityScreen>
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
                  // ── Top bar with Skip ─────────────────────────────────
                  _buildTopBar(),

                  const SizedBox(height: AppSpacing.base),

                  // ── Illustration ──────────────────────────────────────
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
                          child: const CommunityCircleIllustration(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Page Indicator Dots ───────────────────────────────
                  Opacity(
                    opacity: _dotsOpacity.value,
                    child: const OnboardingPageIndicator(
                      currentPage: 0,
                      pageCount: 3,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Title & Subtitle ──────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: _buildTextContent(),
                    ),
                  ),

                  // ── Bottom Buttons ────────────────────────────────────
                  Opacity(
                    opacity: _buttonOpacity.value,
                    child: _buildBottomButtons(),
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
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.buttonMedium,
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
                  text: 'Together we find\n',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'missing people',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Join a compassionate network dedicated\nto reuniting families and keeping our\ncommunity safe.',
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

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: _OnboardingNextButton(
        label: 'Next',
        onPressed: _goToNext,
      ),
    );
  }

  void _goToNext() {
    Navigator.of(context).pushReplacementNamed('/onboarding2');
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }
}

/// Branded "Next" button with arrow icon and gradient effect
/// matching the design reference.
class _OnboardingNextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _OnboardingNextButton({
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
