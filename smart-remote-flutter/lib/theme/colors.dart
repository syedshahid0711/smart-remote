import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF0A0A0F);
  static const Color bg2 = Color(0xFF0F0F1A);
  static const Color bg3 = Color(0xFF13132A);
  
  static const Color card = Color(0x0AFFFFFF);
  static const Color cardBorder = Color(0x1F00D4FF);
  
  static const Color blue = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF7B2FFF);
  static const Color green = Color(0xFF00FF9D);
  static const Color orange = Color(0xFFFF6B35);
  static const Color red = Color(0xFFFF3355);
  
  static const Color text = Color(0xFFE8EAF6);
  static const Color textDim = Color(0xFF8892A4);
  
  // Neon glow shadows
  static List<BoxShadow> neonGlow({Color color = blue, double blurRadius = 15.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: blurRadius,
        spreadRadius: 1.0,
      ),
    ];
  }
}
