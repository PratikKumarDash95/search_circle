import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 15 — Safety Instructions & Guidelines
///
/// Displays priority safety rules that users must acknowledge
/// before proceeding to the evidence camera. Features shield icon,
/// guideline cards, agreement checkbox, and proceed button.
class SafetyGuidelinesScreen extends StatefulWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  State<SafetyGuidelinesScreen> createState() =>
      _SafetyGuidelinesScreenState();
}

class _SafetyGuidelinesScreenState extends State<SafetyGuidelinesScreen>
    with SingleTickerProviderStateMixin {
  bool _agreed = false;

  late final AnimationController _fadeController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _cardsOpacity;
  late final Animation<double> _footerOpacity;

  final List<_SafetyRule> _rules = const [
    _SafetyRule(
      icon: Icons.do_not_touch_rounded,
      title: 'Do not approach',
      description:
          'Avoid making direct contact with the individual to ensure everyone\'s safety. Maintain a neutral stance.',
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEE2E2),
    ),
    _SafetyRule(
      icon: Icons.videocam_rounded,
      title: 'Record safely',
      description:
          'Only take photos or videos if you are in a secure location and it is safe to do so without escalating the situation.',
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFEF3C7),
    ),
    _SafetyRule(
      icon: Icons.social_distance_rounded,
      title: 'Maintain distance',
      description:
          'Keep a safe physical distance while observing. Do not follow if they move away aggressively.',
      iconColor: Color(0xFF12C0A8),
      iconBg: Color(0xFFE0F8F4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _cardsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close_rounded,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Safety Guidelines',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, _) {
          return Column(
            children: [
              const Divider(height: 1, color: AppColors.borderLight),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // ── Shield icon ───────────────────────────────────
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: _buildShieldIcon(),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Title ─────────────────────────────────────────
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: Text(
                          'Priority Safety Rules',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Subtitle ──────────────────────────────────────
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            'Your safety is our top priority. Please review these critical guidelines before submitting a report.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Rule cards ────────────────────────────────────
                      Opacity(
                        opacity: _cardsOpacity.value,
                        child: Column(
                          children: _rules
                              .map((rule) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _RuleCard(rule: rule),
                                  ))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // ── Footer: checkbox + button ─────────────────────────────
              Opacity(
                opacity: _footerOpacity.value,
                child: _buildFooter(),
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

  Widget _buildShieldIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.shield_rounded,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: Column(
        children: [
          // ── Checkbox ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _agreed
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _agreed
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: _agreed
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'I understand and agree to the safety guidelines',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Proceed button ────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: AppSpacing.buttonHeightLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _agreed
                    ? [AppColors.primary, const Color(0xFF4B8AFF)]
                    : [
                        AppColors.primary.withValues(alpha: 0.4),
                        const Color(0xFF4B8AFF).withValues(alpha: 0.4),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: _agreed
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: _agreed
                    ? () {
                        Navigator.of(context).pushNamed('/report');
                      }
                    : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Camera',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Safety rule card with colored icon, title, and description.
class _RuleCard extends StatelessWidget {
  final _SafetyRule rule;

  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ──────────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rule.iconBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              rule.icon,
              size: 24,
              color: rule.iconColor,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Text content ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rule.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _SafetyRule {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBg;

  const _SafetyRule({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBg,
  });
}
