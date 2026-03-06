import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Custom-painted community circle illustration for Onboarding 1.
/// Shows people icons arranged in a circle, holding hands, with
/// a soft blue sky background — replicating the design reference.
class CommunityCircleIllustration extends StatefulWidget {
  const CommunityCircleIllustration({super.key});

  @override
  State<CommunityCircleIllustration> createState() =>
      _CommunityCircleIllustrationState();
}

class _CommunityCircleIllustrationState
    extends State<CommunityCircleIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
            Color(0xFF87CEEB), // Sky blue
            Color(0xFFCDE8F6), // Light sky
            Color(0xFFE8F4FD), // Very light blue
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Subtle cloud shapes ────────────────────────────────────────
          Positioned(
            top: 30,
            left: 20,
            child: _buildCloud(60, 24),
          ),
          Positioned(
            top: 50,
            right: 40,
            child: _buildCloud(45, 18),
          ),
          Positioned(
            top: 80,
            left: 80,
            child: _buildCloud(35, 14),
          ),

          // ── Rotating circle of people ──────────────────────────────────
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 0.05, // Very slow rotation
                child: child,
              );
            },
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _CommunityCirclePainter(),
              ),
            ),
          ),

          // ── Center heart icon ──────────────────────────────────────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}

class _CommunityCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const personCount = 10;

    // ── Draw connecting circle line ──────────────────────────────────────
    final circlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, circlePaint);

    // ── Draw people icons around the circle ──────────────────────────────
    for (int i = 0; i < personCount; i++) {
      final angle = (2 * math.pi / personCount) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Alternate colors between primary and secondary
      final Color personColor = i.isEven
          ? AppColors.primary
          : AppColors.secondary;

      // Person head
      final headPaint = Paint()..color = personColor;
      canvas.drawCircle(Offset(x, y - 6), 7, headPaint);

      // Person body
      final bodyPaint = Paint()
        ..color = personColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y), Offset(x, y + 10), bodyPaint);

      // Arms
      canvas.drawLine(
        Offset(x - 6, y + 3),
        Offset(x + 6, y + 3),
        bodyPaint,
      );

      // Connection line to next person
      final nextAngle =
          (2 * math.pi / personCount) * ((i + 1) % personCount) - math.pi / 2;
      final nextX = center.dx + radius * math.cos(nextAngle);
      final nextY = center.dy + radius * math.sin(nextAngle);

      final connectionPaint = Paint()
        ..color = personColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x + 6 * math.cos(angle + 0.3), y + 3 + 6 * math.sin(angle + 0.3)),
        Offset(
            nextX + 6 * math.cos(nextAngle - 0.3),
            nextY + 3 + 6 * math.sin(nextAngle - 0.3)),
        connectionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
