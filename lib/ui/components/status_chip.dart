import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Status chip used for Verified / Pending / Rejected / Failed / Uploaded etc.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            if (type == StatusType.rejected || type == StatusType.failed)
              Icon(Icons.close, size: 12, color: _foregroundColor)
            else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _foregroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: _foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _foregroundColor {
    switch (type) {
      case StatusType.verified:
        return AppColors.verified;
      case StatusType.pending:
        return AppColors.pending;
      case StatusType.rejected:
        return AppColors.rejected;
      case StatusType.failed:
        return AppColors.failed;
      case StatusType.uploaded:
        return AppColors.uploaded;
      case StatusType.info:
        return AppColors.info;
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusType.verified:
        return AppColors.verifiedBg;
      case StatusType.pending:
        return AppColors.pendingBg;
      case StatusType.rejected:
        return AppColors.rejectedBg;
      case StatusType.failed:
        return AppColors.failedBg;
      case StatusType.uploaded:
        return AppColors.uploadedBg;
      case StatusType.info:
        return AppColors.infoSurface;
    }
  }
}

enum StatusType {
  verified,
  pending,
  rejected,
  failed,
  uploaded,
  info,
}
