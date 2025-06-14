import 'package:flutter/material.dart';

enum BadgeVariant { primary, secondary, outline, destructive, success, warning }

class Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final BadgeVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;

  const Badge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.variant = BadgeVariant.primary,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getBackgroundColor() {
      switch (variant) {
        case BadgeVariant.primary:
          return colorScheme.primary.withValues(alpha: 0.1);
        case BadgeVariant.secondary:
          return colorScheme.secondary.withValues(alpha: 0.1);
        case BadgeVariant.outline:
          return Colors.transparent;
        case BadgeVariant.destructive:
          return colorScheme.error.withValues(alpha: 0.1);
        case BadgeVariant.success:
          return Colors.green.withValues(alpha: 0.1);
        case BadgeVariant.warning:
          return Colors.orange.withValues(alpha: 0.1);
      }
    }

    Color getTextColor() {
      switch (variant) {
        case BadgeVariant.primary:
          return colorScheme.primary;
        case BadgeVariant.secondary:
          return colorScheme.secondary;
        case BadgeVariant.outline:
          return colorScheme.onSurface;
        case BadgeVariant.destructive:
          return colorScheme.error;
        case BadgeVariant.success:
          return Colors.green;
        case BadgeVariant.warning:
          return Colors.orange;
      }
    }

    BorderSide? getBorder() {
      switch (variant) {
        case BadgeVariant.outline:
          return BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.2));
        default:
          return null;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(16),
            border: getBorder() != null
                ? Border.fromBorderSide(getBorder()!)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: getTextColor(), size: 16),
                  child: icon!,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
