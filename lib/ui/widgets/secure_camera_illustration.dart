import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Custom illustration for Onboarding 3 (Action).
/// Shows a stylized phone camera UI with REC badge, encrypted upload
/// banner, and record button — matching the design reference.
class SecureCameraIllustration extends StatefulWidget {
  const SecureCameraIllustration({super.key});

  @override
  State<SecureCameraIllustration> createState() =>
      _SecureCameraIllustrationState();
}

class _SecureCameraIllustrationState extends State<SecureCameraIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _recBlink;
  late final Animation<double> _recOpacity;
  late final AnimationController _pulseController;
  late final Animation<double> _recordPulse;
  late final AnimationController _shieldController;
  late final Animation<double> _shieldSlide;

  @override
  void initState() {
    super.initState();

    // ── REC badge blink ──────────────────────────────────────────────────
    _recBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _recOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _recBlink, curve: Curves.easeInOut),
    );

    // ── Record button pulse ──────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _recordPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Shield banner slide in ───────────────────────────────────────────
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shieldSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _shieldController.forward();
    });
  }

  @override
  void dispose() {
    _recBlink.dispose();
    _pulseController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8EDF8),
            Color(0xFFF0F3FA),
            Color(0xFFF8F9FC),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Phone frame ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 200,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D26),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // ── Camera viewfinder (grey area) ────────────────────
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFBEC5D0),
                      child: CustomPaint(
                        painter: _ViewfinderGridPainter(),
                      ),
                    ),

                    // ── Notch ────────────────────────────────────────────
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1D26),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Top camera controls bar ──────────────────────────
                    Positioned(
                      top: 28,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Flash off icon
                          _buildControlIcon(Icons.flash_off_rounded, 28),

                          // REC badge
                          AnimatedBuilder(
                            animation: _recBlink,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _recOpacity.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'REC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Settings icon
                          _buildControlIcon(Icons.settings_rounded, 28),
                        ],
                      ),
                    ),

                    // ── Inner phone showing reflection ───────────────────
                    Positioned(
                      top: 80,
                      left: 40,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          width: 70,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2D36).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Encrypted Upload banner ────────────────────────────────────
          Positioned(
            bottom: 80,
            child: AnimatedBuilder(
              animation: _shieldController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _shieldSlide.value),
                  child: Opacity(
                    opacity: _shieldController.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3550).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Encrypted Direct Upload Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Record button ──────────────────────────────────────────────
          Positioned(
            bottom: 24,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _recordPulse.value,
                  child: child,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.8),
        size: 16,
      ),
    );
  }
}

/// Draws a subtle grid for the camera viewfinder.
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;

    // Rule of thirds lines
    final third = size.width / 3;
    final thirdH = size.height / 3;

    // Vertical thirds
    canvas.drawLine(
      Offset(third, 0),
      Offset(third, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(third * 2, 0),
      Offset(third * 2, size.height),
      paint,
    );

    // Horizontal thirds
    canvas.drawLine(
      Offset(0, thirdH),
      Offset(size.width, thirdH),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdH * 2),
      Offset(size.width, thirdH * 2),
      paint,
    );

    // Corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const bracketLen = 20.0;
    const margin = 16.0;

    // Top-left bracket
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin + bracketLen, margin),
      bracketPaint,
    );
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin, margin + bracketLen),
      bracketPaint,
    );

    // Top-right bracket
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - bracketLen, margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketLen),
      bracketPaint,
    );

    // Bottom-left bracket
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketLen, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin, size.height - margin - bracketLen),
      bracketPaint,
    );

    // Bottom-right bracket
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - bracketLen, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
