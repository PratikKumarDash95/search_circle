import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Screen 11 — Secure Evidence Camera
///
/// Full-screen recording UI with timer, GPS coordinates,
/// viewfinder brackets, evidence type/storage labels,
/// and a red record button with blue progress ring.
class SecureEvidenceCameraScreen extends StatefulWidget {
  const SecureEvidenceCameraScreen({super.key});

  @override
  State<SecureEvidenceCameraScreen> createState() =>
      _SecureEvidenceCameraScreenState();
}

class _SecureEvidenceCameraScreenState extends State<SecureEvidenceCameraScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _flashOn = false;

  late final AnimationController _fadeController;
  late final Animation<double> _uiOpacity;

  late final AnimationController _recDotController;
  late final Animation<double> _recDotOpacity;

  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _uiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _recDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _recDotOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _recDotController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // 60s max recording
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _recDotController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _elapsedSeconds = 0;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _elapsedSeconds++);
        });
        _recDotController.repeat(reverse: true);
        _ringController.forward(from: 0);
      } else {
        _timer?.cancel();
        _recDotController.stop();
        _recDotController.reset();
        _ringController.stop();
        // Navigate to upload flow
        Navigator.of(context).pushNamed('/upload-history');
      }
    });
  }

  String get _minutes =>
      (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
  String get _seconds =>
      (_elapsedSeconds % 60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _recDotController,
          _ringController,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _uiOpacity.value,
            child: Stack(
              children: [
                // ── Camera background ───────────────────────────────────
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF1A1D26),
                  child: Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                // ── Top controls ────────────────────────────────────────
                _buildTopControls(),

                // ── Timer ───────────────────────────────────────────────
                _buildTimer(),

                // ── GPS badge ───────────────────────────────────────────
                _buildGpsBadge(),

                // ── Viewfinder brackets ─────────────────────────────────
                Center(child: _buildViewfinder()),

                // ── Evidence info bar ───────────────────────────────────
                _buildEvidenceInfo(),

                // ── Bottom controls ─────────────────────────────────────
                _buildBottomControls(),

                // ── Footer text ─────────────────────────────────────────
                _buildFooter(),
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

  Widget _buildTopControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.md,
      left: AppSpacing.screenPadding,
      right: AppSpacing.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Close button ──────────────────────────────────────────────
          _CircleButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),

          // ── Recording badge ───────────────────────────────────────────
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _recDotOpacity.value,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'RECORDING',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFFFF8A8A),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 48),

          // ── Flash toggle ──────────────────────────────────────────────
          _CircleButton(
            icon: _flashOn
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            onTap: () => setState(() => _flashOn = !_flashOn),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    if (!_isRecording) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Minutes
            Text(
              _minutes,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
            // Seconds
            Text(
              _seconds,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsBadge() {
    if (!_isRecording) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 140,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'GPS Locked: 45.4215° N, 75.6972° W',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return SizedBox(
      width: 280,
      height: 260,
      child: CustomPaint(
        painter: _ViewfinderPainter(
          color: _isRecording
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildEvidenceInfo() {
    return Positioned(
      bottom: 180,
      left: AppSpacing.screenPadding,
      right: AppSpacing.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Evidence type ──────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EVIDENCE TYPE',
                style: AppTextStyles.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Video Log #2023-X89',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // ── Storage ───────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'STORAGE',
                style: AppTextStyles.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Encrypted Local',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Info button ────────────────────────────────────────────────
          _CircleButton(
            icon: Icons.info_outline_rounded,
            onTap: () {},
            size: 52,
          ),

          // ── Record button ─────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleRecording,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Progress ring ─────────────────────────────────────
                  if (_isRecording)
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          progress: _ringController.value,
                          ringColor: AppColors.primary,
                          bgColor: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                  // ── Outer ring ────────────────────────────────────────
                  if (!_isRecording)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 4,
                        ),
                      ),
                    ),

                  // ── Inner button ──────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isRecording ? 32 : 56,
                    height: _isRecording ? 32 : 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF4455),
                          Color(0xFFCC2233),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        _isRecording ? 6 : 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Camera flip button ────────────────────────────────────────
          _CircleButton(
            icon: Icons.cameraswitch_rounded,
            onTap: () {},
            size: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      left: AppSpacing.screenPadding,
      right: AppSpacing.screenPadding,
      child: Text(
        'Files are hashed and timestamped immediately.\nGallery access disabled for integrity.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.35),
          height: 1.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS & PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

/// Circular dark button (close, flash, info, camera flip).
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: size * 0.45,
        ),
      ),
    );
  }
}

/// Draws corner bracket viewfinder lines.
class _ViewfinderPainter extends CustomPainter {
  final Color color;

  _ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 35.0;

    // Full frame (thin)
    final framePaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      framePaint,
    );

    // Top-left
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height - len), Offset(0, size.height), paint);
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
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Draws a circular progress ring for recording duration.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color bgColor;

  _ProgressRingPainter({
    required this.progress,
    required this.ringColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 2, bgPaint);

    // Progress arc
    final ringPaint = Paint()
      ..color = ringColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
