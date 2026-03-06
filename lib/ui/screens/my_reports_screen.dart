import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 18 — My Reports
///
/// Lists the user's submitted missing person reports with
/// status indicators (Verified, Pending, Rejected), action
/// buttons (Details, Msg Police), and a center camera FAB.
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  static const List<_ReportItem> _reports = [
    _ReportItem(
      caseId: '#SC-8921',
      name: 'Maria Gonzalez',
      date: 'Oct 24, 2023 • 09:45 AM',
      status: _ReportStatus.verified,
      accentColor: Color(0xFF12C0A8),
      hasActions: true,
    ),
    _ReportItem(
      caseId: '#SC-9045',
      name: 'John Doe Unknown',
      date: 'Today • 2:30 PM',
      status: _ReportStatus.pending,
      accentColor: Color(0xFFF59E0B),
      hasActions: false,
    ),
    _ReportItem(
      caseId: '#SC-8810',
      name: 'Sarah Smith',
      date: 'Oct 15, 2023 • 11:20 AM',
      status: _ReportStatus.rejected,
      accentColor: Color(0xFFEF4444),
      hasActions: false,
      rejectionReason:
          'Duplicate entry detected. Please review verified cases.',
    ),
    _ReportItem(
      caseId: '#SC-8542',
      name: 'David Chen',
      date: 'Sep 30, 2023 • 04:15 PM',
      status: _ReportStatus.verified,
      accentColor: Color(0xFF12C0A8),
      hasActions: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
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
                    'My Reports',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderLight),

            // ── Report list ─────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.lg,
                ),
                itemCount: _reports.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return _ReportCard(report: _reports[index]);
                },
              ),
            ),
          ],
        ),
      ),

      // ── Bottom nav with camera FAB ────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                isSelected: false,
                onTap: () {},
                hasBadge: true,
              ),
              // Center camera FAB
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed('/safety-guidelines'),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF4B8AFF)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                label: 'Reports',
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

/// Report card with left accent bar, status badge, and action buttons.
class _ReportCard extends StatelessWidget {
  final _ReportItem report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Left accent bar ─────────────────────────────────────────
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: report.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CASE ID: ${report.caseId}',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _StatusBadge(status: report.status),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Name
                    Text(
                      report.name,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.date,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    // Rejection reason
                    if (report.rejectionReason != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Text(
                          report.rejectionReason!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    // Action buttons
                    if (report.hasActions) ...[
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          // Details button
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundTertiary,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                                child: InkWell(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/case-detail'),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Details',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),

                          // Msg Police button
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                                child: InkWell(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/police-chat'),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.support_agent_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Msg Police',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge pill.
class _StatusBadge extends StatelessWidget {
  final _ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, Color bg, String label, IconData icon) =
        switch (status) {
      _ReportStatus.verified => (
          const Color(0xFF12C0A8),
          const Color(0xFFE0F8F4),
          'Verified',
          Icons.circle,
        ),
      _ReportStatus.pending => (
          const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7),
          'Pending',
          Icons.circle,
        ),
      _ReportStatus.rejected => (
          const Color(0xFFEF4444),
          const Color(0xFFFEE2E2),
          'Rejected',
          Icons.close_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: status == _ReportStatus.rejected ? 12 : 6,
              color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
  final bool hasBadge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasBadge = false,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
                if (hasBadge)
                  Positioned(
                    right: -3,
                    top: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
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

enum _ReportStatus { verified, pending, rejected }

class _ReportItem {
  final String caseId;
  final String name;
  final String date;
  final _ReportStatus status;
  final Color accentColor;
  final bool hasActions;
  final String? rejectionReason;

  const _ReportItem({
    required this.caseId,
    required this.name,
    required this.date,
    required this.status,
    required this.accentColor,
    required this.hasActions,
    this.rejectionReason,
  });
}
