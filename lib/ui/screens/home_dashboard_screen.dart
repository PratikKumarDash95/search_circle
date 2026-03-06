import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../services/case_service.dart';

/// Screen 9 — Home Dashboard
///
/// Main app screen showing nearby missing person cases,
/// search bar, filter chips, and bottom navigation.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  int _selectedFilterIndex = 0;
  bool _isLoadingCases = true;
  List<Map<String, dynamic>> _apiCases = [];

  late final AnimationController _fadeController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _searchOpacity;
  late final Animation<double> _filtersOpacity;
  late final Animation<double> _listOpacity;

  final List<_FilterChipData> _filters = const [
    _FilterChipData(Icons.location_on_rounded, 'Near Me'),
    _FilterChipData(Icons.warning_amber_rounded, 'Urgent'),
    _FilterChipData(Icons.schedule_rounded, 'Recent'),
    _FilterChipData(Icons.check_circle_outline_rounded, 'Resolved'),
  ];

  // Fallback hardcoded cases (used when API is unavailable)
  final List<_MissingPersonCase> _fallbackCases = const [
    _MissingPersonCase(
      name: 'Sarah Jenkins',
      description: 'Last seen wearing a red jacket near Central Park entrance.',
      distance: '0.8 miles away',
      timeAgo: '2h ago',
      status: _CaseStatus.urgent,
      avatarColor: Color(0xFFE8D5C4),
      avatarIcon: Icons.person_rounded,
    ),
    _MissingPersonCase(
      name: 'David Chen',
      description: 'Missing from downtown area. Height 5\'9".',
      distance: '2.1 miles away',
      timeAgo: '5h ago',
      status: _CaseStatus.active,
      avatarColor: Color(0xFFD5E0F0),
      avatarIcon: Icons.person_rounded,
    ),
    _MissingPersonCase(
      name: 'Robert Miller',
      description: 'Suffers from dementia. May be confused.',
      distance: '3.5 miles away',
      timeAgo: '1h ago',
      status: _CaseStatus.urgent,
      avatarColor: Color(0xFFE0D8D0),
      avatarIcon: Icons.elderly_rounded,
    ),
    _MissingPersonCase(
      name: 'Maria Gonzalez',
      description: 'Located safe by community member.',
      distance: '',
      timeAgo: '',
      status: _CaseStatus.found,
      avatarColor: Color(0xFFD8E8E0),
      avatarIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _searchOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    _filtersOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );

    _listOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final filterNames = ['near_me', 'urgent', 'recent', 'resolved'];
    final filter = filterNames[_selectedFilterIndex];

    try {
      final result = await CaseService.getCases(filter: filter);
      if (mounted && result['success'] == true && result['cases'] != null) {
        setState(() {
          _apiCases = List<Map<String, dynamic>>.from(result['cases']);
          _isLoadingCases = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback to hardcoded
    if (mounted) {
      setState(() => _isLoadingCases = false);
    }
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
              Color(0xFFFCFCFF),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, _) {
              return Column(
                children: [
                  // ── Header ────────────────────────────────────────────
                  Opacity(
                    opacity: _headerOpacity.value,
                    child: _buildHeader(),
                  ),

                  // ── Search bar ────────────────────────────────────────
                  Opacity(
                    opacity: _searchOpacity.value,
                    child: _buildSearchBar(),
                  ),

                  // ── Filter chips ──────────────────────────────────────
                  Opacity(
                    opacity: _filtersOpacity.value,
                    child: _buildFilterChips(),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Case list ─────────────────────────────────────────
                  Expanded(
                    child: Opacity(
                      opacity: _listOpacity.value,
                      child: _buildCaseList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      // ── Report Now FAB ────────────────────────────────────────────────
      floatingActionButton: _buildReportFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ── Bottom Navigation ─────────────────────────────────────────────
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
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // ── Logo ──────────────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Search',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Circle',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // ── Notification bell ──────────────────────────────────────────
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // ── Search field ───────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Search missing persons...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Filter button ─────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    filter.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaseList() {
    return CustomScrollView(
      slivers: [
        // ── Section header ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.base,
              AppSpacing.screenPadding,
              AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Cases Nearby',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/map');
                  },
                  child: Text(
                    'View Map',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Case cards ──────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          sliver: _isLoadingCases
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _apiCases.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final c = _apiCases[index];
                          final status = c['status'] ?? 'active';
                          final caseObj = _MissingPersonCase(
                            name: c['name'] ?? 'Unknown',
                            description: c['description'] ?? '',
                            distance: c['distance'] ?? '',
                            timeAgo: c['time_ago'] ?? '',
                            status: status == 'urgent'
                                ? _CaseStatus.urgent
                                : status == 'found'
                                    ? _CaseStatus.found
                                    : _CaseStatus.active,
                            avatarColor: const Color(0xFFE8D5C4),
                            avatarIcon: Icons.person_rounded,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CaseCard(
                              caseData: caseObj,
                              onTap: () {
                                Navigator.of(context).pushNamed('/case-detail',
                                    arguments: c);
                              },
                            ),
                          );
                        },
                        childCount: _apiCases.length,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CaseCard(
                              caseData: _fallbackCases[index],
                              onTap: () {
                                Navigator.of(context).pushNamed('/case-detail');
                              },
                            ),
                          );
                        },
                        childCount: _fallbackCases.length,
                      ),
                    ),
        ),

        // ── Bottom spacing for FAB ──────────────────────────────────────
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildReportFab() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primary, Color(0xFF4B8AFF)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/report');
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Report Now',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                isSelected: _selectedNavIndex == 1,
                onTap: () => setState(() => _selectedNavIndex = 1),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                isSelected: _selectedNavIndex == 2,
                onTap: () => setState(() => _selectedNavIndex = 2),
                hasBadge: true,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
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

/// Missing person case card.
class _CaseCard extends StatelessWidget {
  final _MissingPersonCase caseData;
  final VoidCallback? onTap;

  const _CaseCard({required this.caseData, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            // ── Avatar placeholder ──────────────────────────────────────
            Container(
              width: 100,
              height: 110,
              decoration: BoxDecoration(
                color: caseData.avatarColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                caseData.avatarIcon,
                size: 48,
                color: caseData.avatarColor
                    .withValues(red: caseData.avatarColor.r * 0.7,
                                green: caseData.avatarColor.g * 0.7,
                                blue: caseData.avatarColor.b * 0.7),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Info ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          caseData.name,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: caseData.status),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Description
                  Text(
                    caseData.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Distance + time
                  Row(
                    children: [
                      if (caseData.distance.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.navigation_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                caseData.distance,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          caseData.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                      if (caseData.status == _CaseStatus.found) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySurface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 13,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Case Closed',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

/// Case status badge (URGENT / FOUND / ACTIVE)
class _StatusBadge extends StatelessWidget {
  final _CaseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, Color bgColor, String label) = switch (status) {
      _CaseStatus.urgent => (AppColors.error, AppColors.errorSurface, 'URGENT'),
      _CaseStatus.found => (
          AppColors.secondary,
          AppColors.secondarySurface,
          'FOUND',
        ),
      _CaseStatus.active => (
          AppColors.primary,
          AppColors.primarySurface,
          'ACTIVE',
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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
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
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
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

class _FilterChipData {
  final IconData icon;
  final String label;

  const _FilterChipData(this.icon, this.label);
}

enum _CaseStatus { urgent, active, found }

class _MissingPersonCase {
  final String name;
  final String description;
  final String distance;
  final String timeAgo;
  final _CaseStatus status;
  final Color avatarColor;
  final IconData avatarIcon;

  const _MissingPersonCase({
    required this.name,
    required this.description,
    required this.distance,
    required this.timeAgo,
    required this.status,
    required this.avatarColor,
    required this.avatarIcon,
  });
}
