import 'package:flutter/material.dart';

/// Design token colors for BuzzMaster.
class AppColors {
  AppColors._();

  // ─── Primary Palette ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D35D8);
  static const Color primaryContainer = Color(0xFF2A2766);

  // ─── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF9F9F);
  static const Color secondaryDark = Color(0xFFD43A3A);

  // ─── Buzz ─────────────────────────────────────────────────────────────────
  static const Color buzzActive = Color(0xFFFF3D3D);
  static const Color buzzGlow = Color(0xFFFF6B6B);
  static const Color buzzDisabled = Color(0xFF666677);
  static const Color buzzWinner = Color(0xFFFFD700);

  // ─── Success / Error / Warning ────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);

  // ─── Dark Theme Surfaces ──────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0E1A);
  static const Color darkSurface = Color(0xFF1A1930);
  static const Color darkSurfaceVariant = Color(0xFF252440);
  static const Color darkCard = Color(0xFF1E1D35);
  static const Color darkDivider = Color(0xFF2E2D4A);

  // ─── Light Theme Surfaces ─────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEDFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE8E7FF);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAB);
  static const Color darkTextDisabled = Color(0xFF666677);
  static const Color lightTextPrimary = Color(0xFF1A1930);
  static const Color lightTextSecondary = Color(0xFF666677);
  static const Color lightTextDisabled = Color(0xFFAAAAAB);

  // ─── Network Signal ───────────────────────────────────────────────────────
  static const Color signalExcellent = Color(0xFF4CAF50);
  static const Color signalGood = Color(0xFF8BC34A);
  static const Color signalFair = Color(0xFFFFC107);
  static const Color signalPoor = Color(0xFFFF5252);

  // ─── Team Colors ──────────────────────────────────────────────────────────
  static const List<Color> teamColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFFFB300),
    Color(0xFFE91E63),
  ];

  // ─── Gradient ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [darkBackground, Color(0xFF1A0B30)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buzzGradient = LinearGradient(
    colors: [Color(0xFFFF3D3D), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient winnerGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
