import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Custom AppBar with safe area handling and consistent styling.
class SafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  const SafeAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.backgroundPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: showBackButton
          ? (leading ??
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppSpacing.iconMd,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ))
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
    );
  }
}
