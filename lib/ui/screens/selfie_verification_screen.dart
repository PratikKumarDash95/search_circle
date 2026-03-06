import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../services/kyc_service.dart';

/// Screen 8 — Selfie Verification
///
/// Face scanning camera UI with oval face guide overlay,
/// instructions, and verification progress. Final step
/// of the 3-step authentication flow (Phone → ID → Selfie).
class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen>
    with TickerProviderStateMixin {
  _SelfieState _selfieState = _SelfieState.ready;
  final _picker = ImagePicker();
  File? _selfieImage;

  late final AnimationController _fadeController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _cameraOpacity;
  late final Animation<double> _instructionsOpacity;
  late final Animation<double> _buttonOpacity;

  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _successController;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    // ── Entrance animations ──────────────────────────────────────────────
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

    _cameraOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _instructionsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Scan line animation ──────────────────────────────────────────────
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // ── Pulse animation (face guide) ─────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Success animation ────────────────────────────────────────────────
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D26),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _scanController,
          _pulseController,
          _successController,
        ]),
        builder: (context, _) {
          return SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                Opacity(
                  opacity: _headerOpacity.value,
                  child: _buildTopBar(),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Step indicator ──────────────────────────────────────
                Opacity(
                  opacity: _headerOpacity.value,
                  child: _buildStepIndicator(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Camera viewport ─────────────────────────────────────
                Expanded(
                  child: Opacity(
                    opacity: _cameraOpacity.value,
                    child: _buildCameraViewport(),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Instructions ────────────────────────────────────────
                Opacity(
                  opacity: _instructionsOpacity.value,
                  child: _buildInstructions(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Capture / Continue button ───────────────────────────
                Opacity(
                  opacity: _buttonOpacity.value,
                  child: _buildActionButton(),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Selfie Verification',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.help_outline_rounded,
              size: 22,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl + AppSpacing.xl,
      ),
      child: Row(
        children: [
          _MiniStepDot(isComplete: true, label: '1'),
          _MiniStepLine(isComplete: true),
          _MiniStepDot(isComplete: true, label: '2'),
          _MiniStepLine(isComplete: _selfieState == _SelfieState.verified),
          _MiniStepDot(
            isComplete: _selfieState == _SelfieState.verified,
            isActive: _selfieState != _SelfieState.verified,
            label: '3',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewport() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D36),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Simulated camera viewfinder ───────────────────────────────
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF3A3D46),
            ),

            // ── Face guide oval ──────────────────────────────────────────
            if (_selfieState != _SelfieState.verified)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: CustomPaint(
                  size: const Size(200, 260),
                  painter: _FaceGuidePainter(
                    isScanning: _selfieState == _SelfieState.scanning,
                    scanProgress: _scanAnimation.value,
                  ),
                ),
              ),

            // ── Scan line ────────────────────────────────────────────────
            if (_selfieState == _SelfieState.scanning)
              Positioned(
                top: 60 + (_scanAnimation.value * 200),
                child: Container(
                  width: 160,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.secondary.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // ── Corner brackets ──────────────────────────────────────────
            if (_selfieState != _SelfieState.verified)
              CustomPaint(
                size: const Size(220, 280),
                painter: _CornerBracketPainter(
                  color: _selfieState == _SelfieState.scanning
                      ? AppColors.secondary
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),

            // ── Success overlay ──────────────────────────────────────────
            if (_selfieState == _SelfieState.verified)
              Transform.scale(
                scale: _successScale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Verification Complete!',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your identity has been verified',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Face icon placeholder ────────────────────────────────────
            if (_selfieState == _SelfieState.ready)
              Icon(
                Icons.face_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.15),
              ),

            // ── Status label ─────────────────────────────────────────────
            if (_selfieState == _SelfieState.scanning)
              Positioned(
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          value: _scanAnimation.value,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Scanning face…',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final String instruction = switch (_selfieState) {
      _SelfieState.ready => 'Position your face within the oval guide',
      _SelfieState.scanning => 'Hold still — verifying your face…',
      _SelfieState.verified => 'You\'re all set! Tap continue below.',
    };

    final List<_InstructionItem> tips = switch (_selfieState) {
      _SelfieState.ready => [
          const _InstructionItem(Icons.wb_sunny_rounded, 'Good lighting'),
          const _InstructionItem(Icons.face_rounded, 'Face forward'),
          const _InstructionItem(
              Icons.visibility_off_rounded, 'No sunglasses'),
        ],
      _SelfieState.scanning => [],
      _SelfieState.verified => [],
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        children: [
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tips.map((tip) {
                return Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        tip.icon,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tip.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final bool isVerified = _selfieState == _SelfieState.verified;
    final bool isScanning = _selfieState == _SelfieState.scanning;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: isScanning
          // ── Scanning: disabled button ──────────────────────────────────
          ? Container(
              width: double.infinity,
              height: AppSpacing.buttonHeightLg + 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Verifying…',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // ── Ready / Verified button ────────────────────────────────────
          : Container(
              width: double.infinity,
              height: AppSpacing.buttonHeightLg + 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isVerified
                      ? [AppColors.secondary, AppColors.secondaryLight]
                      : [AppColors.primary, const Color(0xFF4B8AFF)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: (isVerified ? AppColors.secondary : AppColors.primary)
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: InkWell(
                  onTap: isVerified ? _continue : _capture,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Center(
                    child: Text(
                      isVerified ? 'Continue to SearchCircle' : 'Capture Selfie',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 17,
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

  void _capture() async {
    // Open real camera to take selfie
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    _selfieImage = File(picked.path);
    setState(() => _selfieState = _SelfieState.scanning);
    _pulseController.stop();
    _scanController.repeat();

    // Upload selfie to backend
    final result = await KycService.uploadSelfie(selfieImage: _selfieImage!);

    if (mounted) {
      _scanController.stop();
      if (result['success'] == true) {
        setState(() => _selfieState = _SelfieState.verified);
        _successController.forward();
      } else {
        setState(() => _selfieState = _SelfieState.ready);
        _pulseController.repeat(reverse: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Verification failed')),
        );
      }
    }
  }

  void _continue() {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS & PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

class _InstructionItem {
  final IconData icon;
  final String label;

  const _InstructionItem(this.icon, this.label);
}

enum _SelfieState { ready, scanning, verified }

/// Draws the face guide oval with dashed border.
class _FaceGuidePainter extends CustomPainter {
  final bool isScanning;
  final double scanProgress;

  _FaceGuidePainter({
    required this.isScanning,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final oval = RRect.fromRectAndRadius(rect, Radius.circular(size.width / 2));

    final paint = Paint()
      ..color = isScanning
          ? AppColors.secondary.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw oval
    canvas.drawRRect(oval, paint);

    // If scanning, draw progress arc
    if (isScanning) {
      final progressPaint = Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * scanProgress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.isScanning != isScanning ||
        oldDelegate.scanProgress != scanProgress;
  }
}

/// Draws corner bracket overlays around the face guide.
class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 30.0;

    // Top-left
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height - len),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - len, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Mini step dot for the dark-theme step indicator.
class _MiniStepDot extends StatelessWidget {
  final bool isComplete;
  final bool isActive;
  final String label;

  const _MiniStepDot({
    required this.isComplete,
    this.isActive = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.secondary
            : isActive
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Center(
        child: isComplete
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// Mini step connecting line for the dark-theme step indicator.
class _MiniStepLine extends StatelessWidget {
  final bool isComplete;

  const _MiniStepLine({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isComplete
              ? AppColors.secondary
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
