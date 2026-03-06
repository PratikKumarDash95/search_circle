import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Animated page indicator dots for onboarding.
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}

/// Reusable onboarding page content layout.
/// Shows illustration at top, title + subtitle at bottom.
class OnboardingPageContent extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String highlightedTitle;
  final String subtitle;
  final Color highlightColor;

  const OnboardingPageContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.highlightedTitle,
    required this.subtitle,
    this.highlightColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),

        // ── Illustration ────────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: illustration,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Title (with highlighted part) ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: highlightedTitle,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: highlightColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.base),

        // ── Subtitle ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}
