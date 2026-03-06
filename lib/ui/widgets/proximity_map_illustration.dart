import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Custom-painted map illustration for Onboarding 2 (Proximity).
/// Shows a stylized map grid with location pins and radius circles,
/// replicating the map-based proximity theme from the design reference.
class ProximityMapIllustration extends StatefulWidget {
  const ProximityMapIllustration({super.key});

  @override
  State<ProximityMapIllustration> createState() =>
      _ProximityMapIllustrationState();
}

class _ProximityMapIllustrationState extends State<ProximityMapIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _pinController;
  late final Animation<double> _pin1Bounce;
  late final Animation<double> _pin2Bounce;

  @override
  void initState() {
    super.initState();

    // ── Radar pulse ──────────────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // ── Pin bounce-in ────────────────────────────────────────────────────
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pin1Bounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _pin2Bounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pinController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        color: const Color(0xFFE8F4FD),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _pinController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _MapPainter(
              pulseValue: _pulseAnimation.value,
              pin1Scale: _pin1Bounce.value,
              pin2Scale: _pin2Bounce.value,
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // ── Location pin 1 (teal/heart) ──────────────────────────────
            Positioned(
              left: 80,
              top: 60,
              child: AnimatedBuilder(
                animation: _pinController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pin1Bounce.value,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  );
                },
                child: _buildHeartPin(),
              ),
            ),

            // ── Location pin 2 (blue/dot) ────────────────────────────────
            Positioned(
              right: 70,
              top: 130,
              child: AnimatedBuilder(
                animation: _pinController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pin2Bounce.value,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  );
                },
                child: _buildLocationPin(),
              ),
            ),

            // ── Radar pulse rings ────────────────────────────────────────
            Positioned(
              right: 78,
              top: 138,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: (1.0 - _pulseAnimation.value).clamp(0.0, 0.6),
                    child: Container(
                      width: 80 * _pulseAnimation.value + 16,
                      height: 80 * _pulseAnimation.value + 16,
                      transform: Matrix4.translationValues(
                        -(80 * _pulseAnimation.value) / 2,
                        -(80 * _pulseAnimation.value) / 2,
                        0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── "City Name" label ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: 110,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'San Francisco',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Teal pin with heart icon (matching design reference pin 1)
  Widget _buildHeartPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(AppColors.secondary),
        ),
      ],
    );
  }

  /// Blue location dot pin (matching design reference pin 2)
  Widget _buildLocationPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(AppColors.primary),
        ),
      ],
    );
  }
}

/// Paints the stylized map background with grid, roads, and terrain.
class _MapPainter extends CustomPainter {
  final double pulseValue;
  final double pin1Scale;
  final double pin2Scale;

  _MapPainter({
    required this.pulseValue,
    required this.pin1Scale,
    required this.pin2Scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Water areas ──────────────────────────────────────────────────────
    final waterPaint = Paint()..color = const Color(0xFFCDE8F6);

    // Left water body
    final waterPath1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.15, 0)
      ..quadraticBezierTo(
        size.width * 0.1, size.height * 0.3,
        0, size.height * 0.5,
      )
      ..close();
    canvas.drawPath(waterPath1, waterPaint);

    // Right water body
    final waterPath2 = Path()
      ..moveTo(size.width * 0.85, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.9, size.height * 0.35,
        size.width * 0.85, size.height * 0.1,
      )
      ..close();
    canvas.drawPath(waterPath2, waterPaint);

    // ── Grid lines (roads) ───────────────────────────────────────────────
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    // Horizontal roads
    for (double y = 40; y < size.height; y += 35) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        roadPaint,
      );
    }

    // Vertical roads
    for (double x = 30; x < size.width; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        roadPaint,
      );
    }

    // ── Main roads (thicker) ─────────────────────────────────────────────
    final mainRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3;

    // Horizontal main road
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      mainRoadPaint,
    );

    // Diagonal main road
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.7, size.height),
      mainRoadPaint,
    );

    // ── Park areas ───────────────────────────────────────────────────────
    final parkPaint = Paint()..color = const Color(0xFFD4EDDA).withValues(alpha: 0.5);

    // Park 1
    final park1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.55, 50, 30),
      const Radius.circular(6),
    );
    canvas.drawRRect(park1, parkPaint);

    // Park 2
    final park2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.7, 35, 25),
      const Radius.circular(6),
    );
    canvas.drawRRect(park2, parkPaint);

    // ── Small building dots ──────────────────────────────────────────────
    final buildingPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    final rng = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final bx = rng.nextDouble() * size.width;
      final by = rng.nextDouble() * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, 8 + rng.nextDouble() * 6, 6 + rng.nextDouble() * 4),
          const Radius.circular(2),
        ),
        buildingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.pin1Scale != pin1Scale ||
        oldDelegate.pin2Scale != pin2Scale;
  }
}

/// Draws the downward-pointing triangle tail of a map pin.
class _PinTailPainter extends CustomPainter {
  final Color color;

  _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
