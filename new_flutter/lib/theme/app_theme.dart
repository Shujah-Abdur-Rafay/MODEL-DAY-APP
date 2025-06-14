import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color goldColor = Color(0xFFCDAA7D);
  static const Color goldColorDark = Color(0xFFB8976C);
  static const Color goldColorLight = Color(0xFFE5C896);
  static const Color backgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color surfaceColorLight = Color(0xFF2A2A2A);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color borderColor = Color(0xFF333333);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF808080);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4ECDC4);
  static const Color warningColor = Color(0xFFFFE66D);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Card Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: shadowSm,
  );

  static BoxDecoration cardDecorationElevated = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: shadowMd,
  );

  static BoxDecoration cardDecorationGold = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 1),
    boxShadow: shadowMd,
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: goldColor,
    foregroundColor: Colors.black,
    padding:
        const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: const Size(88, 44),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: surfaceColor,
    foregroundColor: textPrimary,
    padding:
        const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: const Size(88, 44),
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: goldColor,
    side: const BorderSide(color: goldColor, width: 1),
    padding:
        const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    minimumSize: const Size(88, 44),
  );

  static ButtonStyle ghostButtonStyle = TextButton.styleFrom(
    foregroundColor: textPrimary,
    padding:
        const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
    minimumSize: const Size(44, 44),
  );

  // Input Decorations
  static InputDecoration textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: goldColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
    // Ensure consistent text styling
    labelStyle: const TextStyle(color: textPrimary),
    floatingLabelStyle: const TextStyle(color: goldColor),
    hintStyle: const TextStyle(color: textMuted),
  );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textMuted,
    height: 1.4,
  );
}
