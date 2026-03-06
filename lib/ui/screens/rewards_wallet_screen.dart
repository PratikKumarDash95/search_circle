import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 14 — Community Rewards Wallet
///
/// Displays total earned coins, withdraw option, and a tabbed
/// transaction history (Approved / Pending / Rejected).
class RewardsWalletScreen extends StatefulWidget {
  const RewardsWalletScreen({super.key});

  @override
  State<RewardsWalletScreen> createState() => _RewardsWalletScreenState();
}

class _RewardsWalletScreenState extends State<RewardsWalletScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final AnimationController _fadeController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _listOpacity;

  final List<_RewardTransaction> _approved = const [
    _RewardTransaction(
      title: 'Found Missing Person',
      subtitle: 'Case #4921 • Oct 24, 2023',
      coins: 500,
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF22C55E),
      iconBg: Color(0xFFDCFCE7),
    ),
    _RewardTransaction(
      title: 'Shared Alert',
      subtitle: 'Case #3301 • Oct 22, 2023',
      coins: 50,
      icon: Icons.share_rounded,
      iconColor: Color(0xFF2369FF),
      iconBg: Color(0xFFE8F0FF),
    ),
    _RewardTransaction(
      title: 'Location Update',
      subtitle: 'Case #8821 • Oct 20, 2023',
      coins: 150,
      icon: Icons.location_on_rounded,
      iconColor: Color(0xFF9333EA),
      iconBg: Color(0xFFF3E8FF),
    ),
    _RewardTransaction(
      title: 'Referral Bonus',
      subtitle: 'Invite • Oct 15, 2023',
      coins: 200,
      icon: Icons.person_add_rounded,
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEE2E2),
    ),
    _RewardTransaction(
      title: 'Shared Alert',
      subtitle: 'Case #1290 • Oct 10, 2023',
      coins: 50,
      icon: Icons.share_rounded,
      iconColor: Color(0xFF2369FF),
      iconBg: Color(0xFFE8F0FF),
    ),
  ];

  final List<_RewardTransaction> _pending = const [
    _RewardTransaction(
      title: 'Sighting Report',
      subtitle: 'Case #9102 • Oct 25, 2023',
      coins: 100,
      icon: Icons.visibility_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFEF3C7),
    ),
  ];

  final List<_RewardTransaction> _rejected = const [
    _RewardTransaction(
      title: 'Duplicate Report',
      subtitle: 'Case #7710 • Oct 18, 2023',
      coins: 0,
      icon: Icons.cancel_rounded,
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEE2E2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _listOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'My Wallet',
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
              // ── Balance card ──────────────────────────────────────────
              Opacity(
                opacity: _headerOpacity.value,
                child: _buildBalanceCard(),
              ),

              // ── Withdraw button ───────────────────────────────────────
              Opacity(
                opacity: _headerOpacity.value,
                child: _buildWithdrawButton(),
              ),

              // ── Tab bar ───────────────────────────────────────────────
              Opacity(
                opacity: _listOpacity.value,
                child: _buildTabBar(),
              ),

              // ── Transaction list ──────────────────────────────────────
              Expanded(
                child: Opacity(
                  opacity: _listOpacity.value,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionList(_approved),
                      _buildTransactionList(_pending),
                      _buildTransactionList(_rejected),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2369FF),
            Color(0xFF4B8AFF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Earned',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Coin amount ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentDark.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '1,250',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Growth badge ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  '+15% this month',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Withdraw to Bank',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Approved'),
          Tab(text: 'Pending'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<_RewardTransaction> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 48,
                color: AppColors.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('No transactions', style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary)),
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
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        return _TransactionTile(transaction: items[index]);
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
                icon: Icons.monetization_on_rounded,
                label: 'Rewards',
                isSelected: true,
                onTap: () {},
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

class _TransactionTile extends StatelessWidget {
  final _RewardTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transaction.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.icon,
              size: 22,
              color: transaction.iconColor,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Title + subtitle ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // ── Coins ─────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.coins > 0 ? '+${transaction.coins}' : '0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: transaction.coins > 0
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
              Text(
                'Coins',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _RewardTransaction {
  final String title;
  final String subtitle;
  final int coins;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _RewardTransaction({
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}
