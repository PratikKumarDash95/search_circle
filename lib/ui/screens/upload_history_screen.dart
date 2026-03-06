import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 12 — Upload History & Status
///
/// Shows all evidence uploads organized by tabs (Pending, Uploaded, Failed).
/// Each card shows thumbnail, status badge, case ID, file type, size,
/// progress bar, and action buttons.
class UploadHistoryScreen extends StatefulWidget {
  const UploadHistoryScreen({super.key});

  @override
  State<UploadHistoryScreen> createState() => _UploadHistoryScreenState();
}

class _UploadHistoryScreenState extends State<UploadHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_UploadItem> _pendingItems = const [
    _UploadItem(
      status: _UploadStatus.waitingForNetwork,
      caseId: '#SC-2023-8492',
      fileType: 'Video Report',
      fileSize: '14.2 MB',
      timeAgo: '',
      progress: 0.4,
      thumbColor: Color(0xFF3A3530),
      thumbIcon: Icons.play_circle_filled_rounded,
    ),
    _UploadItem(
      status: _UploadStatus.uploadFailed,
      caseId: '#SC-2023-8411',
      fileType: 'Geo-Location Data',
      fileSize: '1.2 MB',
      timeAgo: '',
      progress: 0.0,
      thumbColor: Color(0xFFD4C8A0),
      thumbIcon: Icons.warning_amber_rounded,
    ),
    _UploadItem(
      status: _UploadStatus.underReview,
      caseId: '#SC-2023-8300',
      fileType: 'Photo Evidence (5)',
      fileSize: '8.5 MB',
      timeAgo: 'Uploaded 2 hours ago',
      progress: 1.0,
      thumbColor: Color(0xFFC8B888),
      thumbIcon: Icons.photo_library_rounded,
    ),
    _UploadItem(
      status: _UploadStatus.resolved,
      caseId: '#SC-2023-8105',
      fileType: 'Audio Report',
      fileSize: '2.1 MB',
      timeAgo: 'Uploaded yesterday',
      progress: 1.0,
      thumbColor: Color(0xFF88A8C0),
      thumbIcon: Icons.landscape_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Upload History',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // ── Connectivity banner ───────────────────────────────────────
          _buildConnectivityBanner(),

          // ── Tab bar ───────────────────────────────────────────────────
          _buildTabBar(),

          // ── Tab views ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUploadList(_pendingItems),
                _buildUploadList(_pendingItems
                    .where((i) =>
                        i.status == _UploadStatus.underReview ||
                        i.status == _UploadStatus.resolved)
                    .toList()),
                _buildUploadList(_pendingItems
                    .where(
                        (i) => i.status == _UploadStatus.uploadFailed)
                    .toList()),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildConnectivityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm + 2,
      ),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'No Internet – Uploads will be queued.',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Uploaded'),
          Tab(text: 'Failed'),
        ],
      ),
    );
  }

  Widget _buildUploadList(List<_UploadItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done_rounded,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No items here',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return _UploadCard(item: items[index]);
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
                onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                isSelected: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.cloud_upload_rounded,
                label: 'Uploads',
                isSelected: true,
                onTap: () {},
                hasBadge: true,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: false,
                onTap: () {},
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

/// Upload card displaying file info, status, progress, and actions.
class _UploadCard extends StatelessWidget {
  final _UploadItem item;

  const _UploadCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Thumbnail ─────────────────────────────────────────────
              Container(
                width: 100,
                height: 90,
                decoration: BoxDecoration(
                  color: item.thumbColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  item.thumbIcon,
                  size: 36,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Info ──────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    _StatusBadge(status: item.status),
                    const SizedBox(height: AppSpacing.xs),

                    // Case ID
                    Text(
                      'Case ID: ${item.caseId}',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // File type + size
                    Text(
                      '${item.fileType} • ${item.fileSize}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Time ago or actions
                    if (item.timeAgo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],

                    if (item.status == _UploadStatus.waitingForNetwork) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ActionChip(
                          icon: Icons.refresh_rounded,
                          label: 'Retry Upload',
                          outlined: true,
                        ),
                      ),
                    ],

                    if (item.status == _UploadStatus.uploadFailed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ActionChip(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            outlined: true,
                            isDestructive: true,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ActionChip(
                            icon: Icons.refresh_rounded,
                            label: 'Retry',
                            filled: true,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Progress bar ──────────────────────────────────────────────
          if (item.status == _UploadStatus.waitingForNetwork &&
              item.progress > 0) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor: AppColors.backgroundTertiary,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Status badge for upload items.
class _StatusBadge extends StatelessWidget {
  final _UploadStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, Color bgColor, String label, IconData icon) =
        switch (status) {
      _UploadStatus.waitingForNetwork => (
          const Color(0xFFE0A800),
          AppColors.warningSurface,
          'WAITING FOR NETWORK',
          Icons.schedule_rounded,
        ),
      _UploadStatus.uploadFailed => (
          AppColors.error,
          AppColors.errorSurface,
          'UPLOAD FAILED',
          Icons.error_outline_rounded,
        ),
      _UploadStatus.underReview => (
          AppColors.warning,
          AppColors.warningSurface,
          'UNDER REVIEW',
          Icons.visibility_rounded,
        ),
      _UploadStatus.resolved => (
          AppColors.secondary,
          AppColors.secondarySurface,
          'RESOLVED',
          Icons.check_circle_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small action chip button (Retry, Delete, etc.)
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool outlined;
  final bool filled;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.outlined = false,
    this.filled = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.textSecondary
        : filled
            ? Colors.white
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: outlined
            ? Border.all(
                color: isDestructive
                    ? AppColors.border
                    : AppColors.primary.withValues(alpha: 0.4),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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

/// Bottom navigation item.
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
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
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
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
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

enum _UploadStatus {
  waitingForNetwork,
  uploadFailed,
  underReview,
  resolved,
}

class _UploadItem {
  final _UploadStatus status;
  final String caseId;
  final String fileType;
  final String fileSize;
  final String timeAgo;
  final double progress;
  final Color thumbColor;
  final IconData thumbIcon;

  const _UploadItem({
    required this.status,
    required this.caseId,
    required this.fileType,
    required this.fileSize,
    required this.timeAgo,
    required this.progress,
    required this.thumbColor,
    required this.thumbIcon,
  });
}
