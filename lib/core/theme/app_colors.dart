import 'package:flutter/material.dart';

/// Color palette: Deep Navy (#0B1D3A), White, and Safety Orange (#FF6B35).
class AppColors {
  AppColors._();

  // --- Brand core ---
  static const Color deepNavy = Color(0xFF0B1D3A);
  static const Color safetyOrange = Color(0xFFFF6B35);
  static const Color white = Color(0xFFFFFFFF);

  // --- Navy shades (surfaces / cards on the dark industrial theme) ---
  static const Color navy900 = Color(0xFF081427); // deepest background
  static const Color navy800 = Color(0xFF0B1D3A); // base background
  static const Color navy700 = Color(0xFF13294B); // elevated surface
  static const Color navy600 = Color(0xFF1C3A66); // cards / inputs
  static const Color navy500 = Color(0xFF2A4D80); // borders / dividers

  // --- Orange shades ---
  static const Color orange600 = Color(0xFFE85A28);
  static const Color orange400 = Color(0xFFFF8A5E);

  // --- Semantic / status colors ---
  static const Color success = Color(0xFF22C55E); // "In Area", clock-in OK
  static const Color danger = Color(0xFFEF4444); // "Outside Area", errors
  static const Color warning = Color(0xFFF59E0B); // late / izin
  static const Color info = Color(0xFF38BDF8);

  // --- Text ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB6C2D9);
  static const Color textMuted = Color(0xFF7A8AA8);
  static const Color textOnLight = Color(0xFF0B1D3A);

  // --- Light theme surfaces (used when dark mode is toggled off) ---
  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
}
