import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../services/kyc_service.dart';

/// Screen 7 — ID Verification Upload
///
/// Users upload a government-issued photo ID (front + back).
/// Shows upload zones with drag-drop style UI, document type selector,
/// and a submit button. Part of the authentication flow.
class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen>
    with SingleTickerProviderStateMixin {
  _DocType _selectedDocType = _DocType.nationalId;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _isSubmitting = false;
  File? _frontImage;
  File? _backImage;
  final _picker = ImagePicker();

  late final AnimationController _fadeController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _selectorOpacity;
  late final Animation<double> _uploadOpacity;
  late final Animation<double> _tipsOpacity;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _selectorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    _uploadOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _tipsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
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
          'Identity Verification',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _skipForNow,
            child: Text(
              'Skip',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.base),

                      // ── Header ────────────────────────────────────────
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: _buildHeader(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Step indicator ────────────────────────────────
                      Opacity(
                        opacity: _headerOpacity.value,
                        child: _buildStepIndicator(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Document type selector ────────────────────────
                      Opacity(
                        opacity: _selectorOpacity.value,
                        child: _buildDocTypeSelector(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Upload zones ──────────────────────────────────
                      Opacity(
                        opacity: _uploadOpacity.value,
                        child: _buildUploadZones(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Tips ──────────────────────────────────────────
                      Opacity(
                        opacity: _tipsOpacity.value,
                        child: _buildTips(),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // ── Submit button ─────────────────────────────────────────
              Opacity(
                opacity: _buttonOpacity.value,
                child: _buildSubmitButton(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Shield icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Verify Your Identity',
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Upload a government-issued photo ID to\nverify your identity and unlock all features.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(label: 'Phone', isComplete: true, isActive: false),
        _StepLine(isComplete: true),
        _StepDot(label: 'ID Upload', isComplete: false, isActive: true),
        _StepLine(isComplete: false),
        _StepDot(label: 'Selfie', isComplete: false, isActive: false),
      ],
    );
  }

  Widget _buildDocTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOCUMENT TYPE',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: _DocType.values.map((type) {
            final isSelected = _selectedDocType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDocType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: type != _DocType.values.last
                        ? AppSpacing.sm
                        : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySurface
                        : AppColors.backgroundSecondary,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type.icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUploadZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPLOAD PHOTOS',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Front side ──────────────────────────────────────────────────
        _UploadZone(
          label: 'Front Side',
          sublabel: 'Take a clear photo of the front',
          icon: Icons.credit_card_rounded,
          isUploaded: _frontUploaded,
          onTap: () => setState(() => _frontUploaded = !_frontUploaded),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Back side ───────────────────────────────────────────────────
        _UploadZone(
          label: 'Back Side',
          sublabel: 'Take a clear photo of the back',
          icon: Icons.flip_rounded,
          isUploaded: _backUploaded,
          onTap: () => setState(() => _backUploaded = !_backUploaded),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.accentDark,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tips for a successful upload',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TipItem(text: 'Place your ID on a flat, dark surface'),
          const SizedBox(height: AppSpacing.sm),
          _TipItem(text: 'Ensure all corners are visible'),
          const SizedBox(height: AppSpacing.sm),
          _TipItem(text: 'Avoid glare and shadows'),
          const SizedBox(height: AppSpacing.sm),
          _TipItem(text: 'Make sure text is readable'),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _frontUploaded && _backUploaded;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: AppSpacing.buttonHeightLg + 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: canSubmit
                ? [AppColors.primary, const Color(0xFF4B8AFF)]
                : [
                    AppColors.primary.withValues(alpha: 0.4),
                    const Color(0xFF4B8AFF).withValues(alpha: 0.4),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: canSubmit
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: canSubmit && !_isSubmitting ? _submit : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Continue to Selfie Verification',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _pickImage(bool isFront) async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(picked.path);
          _frontUploaded = true;
        } else {
          _backImage = File(picked.path);
          _backUploaded = true;
        }
      });
    }
  }

  void _submit() async {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both front and back of your ID')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final docTypeMap = {
      _DocType.nationalId: 'national_id',
      _DocType.passport: 'passport',
      _DocType.driverLicense: 'driver_license',
    };

    final result = await KycService.uploadId(
      frontImage: _frontImage!,
      backImage: _backImage!,
      docType: docTypeMap[_selectedDocType] ?? 'national_id',
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success'] == true) {
        Navigator.of(context).pushReplacementNamed('/selfie-verification');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Upload failed')),
        );
      }
    }
  }

  void _skipForNow() {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Upload zone with dashed border, icon, and uploaded state.
class _UploadZone extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onTap;

  const _UploadZone({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.secondarySurface
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isUploaded
                ? AppColors.secondary
                : AppColors.border,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon container ──────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded ? AppColors.secondary : AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: AppSpacing.base),

            // ── Text ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? 'Uploaded successfully' : sublabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUploaded
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Action icon ─────────────────────────────────────────────
            Icon(
              isUploaded
                  ? Icons.check_circle_rounded
                  : Icons.camera_alt_outlined,
              color: isUploaded ? AppColors.secondary : AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step progress dot.
class _StepDot extends StatelessWidget {
  final String label;
  final bool isComplete;
  final bool isActive;

  const _StepDot({
    required this.label,
    required this.isComplete,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.secondary
                : isActive
                    ? AppColors.primary
                    : AppColors.backgroundTertiary,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: isComplete
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : isActive
                  ? const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14)
                  : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive
                ? AppColors.primary
                : isComplete
                    ? AppColors.secondary
                    : AppColors.textTertiary,
            fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Step connecting line.
class _StepLine extends StatelessWidget {
  final bool isComplete;

  const _StepLine({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(
          bottom: AppSpacing.lg,
          left: AppSpacing.xs,
          right: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.secondary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Tip item with checkmark.
class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 12,
            color: AppColors.accentDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accentDark,
            ),
          ),
        ),
      ],
    );
  }
}

enum _DocType {
  nationalId(Icons.badge_rounded, 'National ID'),
  passport(Icons.menu_book_rounded, 'Passport'),
  driverLicense(Icons.directions_car_rounded, "Driver's\nLicense");

  final IconData icon;
  final String label;

  const _DocType(this.icon, this.label);
}
