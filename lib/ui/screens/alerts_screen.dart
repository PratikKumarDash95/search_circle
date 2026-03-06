import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 19 — Alerts & Notifications
///
/// Displays real-time alerts for nearby missing person sightings,
/// case updates, system notifications, and community messages.
/// Grouped by recency (Today / Yesterday / Earlier).
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _contentOpacity;

  final List<_AlertGroup> _groups = [
    _AlertGroup(
      label: 'Today',
      alerts: [
        _AlertItem(
          type: _AlertType.urgentSighting,
          title: 'Urgent: New Sighting Reported',
          body:
              'A possible sighting of Maria Gonzalez was reported near Pioneer Square, 0.3 mi from you.',
          time: '12 min ago',
          isUnread: true,
          caseId: '#SC-8921',
        ),
        _AlertItem(
          type: _AlertType.caseUpdate,
          title: 'Case Update — John Doe',
          body:
              'Police have confirmed your sighting report. An officer has been dispatched to the area.',
          time: '45 min ago',
          isUnread: true,
          caseId: '#SC-9045',
        ),
        _AlertItem(
          type: _AlertType.reward,
          title: 'Reward Earned: +150 Coins',
          body:
              'You received 150 coins for submitting a verified location update on Case #8821.',
          time: '2h ago',
          isUnread: false,
        ),
      ],
    ),
    _AlertGroup(
      label: 'Yesterday',
      alerts: [
        _AlertItem(
          type: _AlertType.community,
          title: 'Community Alert – Your Area',
          body:
              '3 new missing person cases have been filed within 5 miles of your location. Stay vigilant.',
          time: 'Yesterday, 6:30 PM',
          isUnread: false,
        ),
        _AlertItem(
          type: _AlertType.policeMessage,
          title: 'Message from Officer Miller',
          body:
              'Thank you for your cooperation. We\'ve closed Case #SC-8105 as resolved.',
          time: 'Yesterday, 2:15 PM',
          isUnread: false,
          caseId: '#SC-8105',
        ),
      ],
    ),
    _AlertGroup(
      label: 'Earlier',
      alerts: [
        _AlertItem(
          type: _AlertType.system,
          title: 'Identity Verification Complete',
          body:
              'Your identity has been verified. You are now authorized to join search parties.',
          time: 'Oct 22, 2023',
          isUnread: false,
        ),
        _AlertItem(
          type: _AlertType.community,
          title: 'Welcome to SearchCircle!',
          body:
              'Thank you for joining our community. Together we can make a difference.',
          time: 'Oct 20, 2023',
          isUnread: false,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
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
      backgroundColor: const Color(0xFFF8F9FC),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, _) {
          return Opacity(
            opacity: _contentOpacity.value,
            child: SafeArea(
              child: Column(
                children: [
                  // ── Header ────────────────────────────────────────────
                  _buildHeader(),
                  const Divider(height: 1, color: AppColors.borderLight),

                  // ── Alert list ────────────────────────────────────────
                  Expanded(child: _buildAlertList()),
                ],
              ),
            ),
          );
        },
      ),

      // ── Bottom nav ────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Alerts',
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              // Unread count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '2 New',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Mark all read
              GestureDetector(
                onTap: () {
                  setState(() {
                    for (final group in _groups) {
                      for (final alert in group.alerts) {
                        alert.isUnread = false;
                      }
                    }
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(
                    Icons.done_all_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      itemCount: _groups.length,
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: AppSpacing.lg),

            // Group label
            Text(
              group.label,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Alert cards
            ...group.alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _AlertCard(
                    alert: alert,
                    onTap: () {
                      setState(() => alert.isUnread = false);
                      if (alert.caseId != null) {
                        Navigator.of(context).pushNamed('/case-detail');
                      }
                    },
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: false,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.notifications_rounded,
                label: 'Alerts',
                isSelected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: false,
                onTap: () =>
                    Navigator.of(context).pushNamed('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Single alert card with icon, content, time, and unread indicator.
class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  final VoidCallback onTap;

  const _AlertCard({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color iconColor, Color iconBg) = switch (alert.type) {
      _AlertType.urgentSighting => (
          Icons.warning_amber_rounded,
          const Color(0xFFEF4444),
          const Color(0xFFFEE2E2),
        ),
      _AlertType.caseUpdate => (
          Icons.update_rounded,
          AppColors.primary,
          AppColors.primarySurface,
        ),
      _AlertType.reward => (
          Icons.monetization_on_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7),
        ),
      _AlertType.community => (
          Icons.groups_rounded,
          const Color(0xFF9333EA),
          const Color(0xFFF3E8FF),
        ),
      _AlertType.policeMessage => (
          Icons.local_police_rounded,
          const Color(0xFF12C0A8),
          const Color(0xFFE0F8F4),
        ),
      _AlertType.system => (
          Icons.verified_rounded,
          AppColors.primary,
          AppColors.primarySurface,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: alert.isUnread
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: alert.isUnread
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ────────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (alert.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    alert.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (alert.caseId != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            alert.caseId!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom nav item.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

enum _AlertType {
  urgentSighting,
  caseUpdate,
  reward,
  community,
  policeMessage,
  system,
}

class _AlertGroup {
  final String label;
  final List<_AlertItem> alerts;

  const _AlertGroup({required this.label, required this.alerts});
}

class _AlertItem {
  final _AlertType type;
  final String title;
  final String body;
  final String time;
  bool isUnread;
  final String? caseId;

  _AlertItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    this.caseId,
  });
}
