import 'package:flutter/material.dart';

/// SearchCircle Design System — Color Palette
class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2369FF);
  static const Color primaryLight = Color(0xFF5A8FFF);
  static const Color primaryDark = Color(0xFF0A4FD6);
  static const Color primarySurface = Color(0xFFE8F0FF);

  static const Color secondary = Color(0xFF12C0A8);
  static const Color secondaryLight = Color(0xFF4DD9C5);
  static const Color secondaryDark = Color(0xFF0A9A87);
  static const Color secondarySurface = Color(0xFFE0F8F4);

  static const Color accent = Color(0xFFFFC745);
  static const Color accentLight = Color(0xFFFFD97A);
  static const Color accentDark = Color(0xFFE0A800);
  static const Color accentSurface = Color(0xFFFFF5DC);

  // ── Neutral Colors ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8F9FC);
  static const Color backgroundTertiary = Color(0xFFF1F3F8);

  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF8F9FC);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F1F4);
  static const Color divider = Color(0xFFEEEFF2);

  // ── Status Colors ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFDBEAFE);

  // ── Status Chip Colors ────────────────────────────────────────────────
  static const Color verified = Color(0xFF12C0A8);
  static const Color verifiedBg = Color(0xFFE0F8F4);
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color rejected = Color(0xFFEF4444);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color failed = Color(0xFFEF4444);
  static const Color failedBg = Color(0xFFFEE2E2);
  static const Color uploaded = Color(0xFF22C55E);
  static const Color uploadedBg = Color(0xFFDCFCE7);

  // ── Gradient ──────────────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFDAE3F8),
      Color(0xFFF2F5FC),
      Color(0xFFFFFFFF),
      Color(0xFFF2F5FC),
      Color(0xFFDAE3F8),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF4B8AFF)],
  );

  // ── Shadows ───────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF2369FF).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF2369FF).withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
