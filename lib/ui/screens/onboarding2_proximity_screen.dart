import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/onboarding_widgets.dart';
import '../widgets/proximity_map_illustration.dart';

/// Screen 3 — Onboarding 2: Proximity
///
/// Second onboarding page: "Help keep your community safe"
/// Shows map illustration with location pins, page dots (2/3 active),
/// "Next" button, back arrow, and "Skip onboarding" text.
class Onboarding2ProximityScreen extends StatefulWidget {
  const Onboarding2ProximityScreen({super.key});

  @override
  State<Onboarding2ProximityScreen> createState() =>
      _Onboarding2ProximityScreenState();
}

class _Onboarding2ProximityScreenState
    extends State<Onboarding2ProximityScreen>
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
                  // ── Top bar with back + title + skip ───────────────────
                  _buildTopBar(),

                  const SizedBox(height: AppSpacing.base),

                  // ── Map Illustration ───────────────────────────────────
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
                          child: const ProximityMapIllustration(),
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
                      currentPage: 1,
                      pageCount: 3,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Bottom Buttons ────────────────────────────────────
                  Opacity(
                    opacity: _buttonOpacity.value,
                    child: _buildBottomButtons(),
                  ),

                  const SizedBox(height: AppSpacing.base),

                  // ── Skip onboarding text ──────────────────────────────
                  Opacity(
                    opacity: _buttonOpacity.value,
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: AppTextStyles.bodyMedium,
                      ),
                      child: const Text('Skip onboarding'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.base),
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

          // ── Title ──────────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Search',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Circle',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Spacer to balance back button ──────────────────────────────
          const SizedBox(width: 48),
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
          Text(
            'Help keep your\ncommunity safe',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Proximity alerts help you stay informed\nabout safety events in your neighborhood\nin real-time.',
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
    Navigator.of(context).pushReplacementNamed('/onboarding3');
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }
}

/// Branded "Next" button with arrow icon and gradient effect.
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
