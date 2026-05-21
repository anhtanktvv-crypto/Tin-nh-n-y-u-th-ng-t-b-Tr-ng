import 'package:flutter/material.dart';

class AppTheme {
  // ================== GRADIENTS ==================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE6F2),
      Color(0xFFFFB3D9),
      Color(0xFFFF80BF),
      Color(0xFFFF66B2),
    ],
  );

  static const LinearGradient loveGradient = LinearGradient(
    colors: [Colors.pinkAccent, Colors.redAccent],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Colors.purpleAccent, Colors.pinkAccent],
  );

  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.15),
      Colors.white.withValues(alpha: 0.05),
    ],
  );

  // ================== COLORS ==================
  static const Color primaryPink = Color(0xFFFF66B2);
  static const Color softPink = Color(0xFFFFE6F2);
  static const Color accentPink = Colors.pinkAccent;
  static const Color accentBlue = Colors.blueAccent;
  static const Color accentPurple = Colors.purpleAccent;
  static const Color accentGreen = Colors.greenAccent;
  static const Color accentOrange = Colors.orangeAccent;
  static const Color accentCyan = Colors.cyan;

  // ================== TEXT STYLES ==================
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [Shadow(color: Colors.pink, blurRadius: 10)],
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    color: Colors.white70,
  );

  static const TextStyle hintStyle = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  // ================== DECORATIONS ==================
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
  );

  static BoxDecoration glassDecorationSmall = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
  );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: Colors.black.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
  );

  static BoxDecoration glassCard({Color? borderColor}) {
    return BoxDecoration(
      gradient: glassGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor?.withValues(alpha: 0.5) ??
            Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }

  // ================== SHADOWS ==================
  static List<BoxShadow> softShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> glowShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.5),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ];
  }

  // ================== BUTTON STYLES ==================
  static ButtonStyle glassButton(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor.withValues(alpha: 0.3),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: bgColor.withValues(alpha: 0.5), width: 1),
      ),
    );
  }

  // ================== RESPONSIVE ==================
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 800;

  static double getResponsiveFont(
      BuildContext context, double mobile, double desktop) {
    return isDesktop(context) ? desktop : mobile;
  }
}