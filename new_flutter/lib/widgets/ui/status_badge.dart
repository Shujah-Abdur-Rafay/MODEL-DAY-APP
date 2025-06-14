import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum BadgeVariant { 
  primary, 
  secondary, 
  success, 
  warning, 
  error, 
  info,
  outline,
}

enum BadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final BadgeSize size;
  final IconData? icon;
  final Color? customColor;
  final Color? customTextColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.medium,
    this.icon,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getBadgeColors();
    final dimensions = _getBadgeDimensions();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.horizontalPadding,
        vertical: dimensions.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: variant == BadgeVariant.outline 
            ? Border.all(color: colors.textColor, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: dimensions.iconSize,
              color: colors.textColor,
            ),
            SizedBox(width: dimensions.iconSpacing),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: dimensions.fontSize,
              fontWeight: FontWeight.w500,
              color: colors.textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  BadgeColors _getBadgeColors() {
    if (customColor != null) {
      return BadgeColors(
        backgroundColor: customColor!,
        textColor: customTextColor ?? Colors.white,
      );
    }

    switch (variant) {
      case BadgeVariant.primary:
        return BadgeColors(
          backgroundColor: AppTheme.goldColor.withValues(alpha: 0.15),
          textColor: AppTheme.goldColor,
        );
      case BadgeVariant.secondary:
        return BadgeColors(
          backgroundColor: AppTheme.surfaceColor,
          textColor: AppTheme.textSecondary,
        );
      case BadgeVariant.success:
        return BadgeColors(
          backgroundColor: AppTheme.successColor.withValues(alpha: 0.15),
          textColor: AppTheme.successColor,
        );
      case BadgeVariant.warning:
        return BadgeColors(
          backgroundColor: AppTheme.warningColor.withValues(alpha: 0.15),
          textColor: AppTheme.warningColor,
        );
      case BadgeVariant.error:
        return BadgeColors(
          backgroundColor: AppTheme.errorColor.withValues(alpha: 0.15),
          textColor: AppTheme.errorColor,
        );
      case BadgeVariant.info:
        return BadgeColors(
          backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.15),
          textColor: AppTheme.textSecondary,
        );
      case BadgeVariant.outline:
        return BadgeColors(
          backgroundColor: Colors.transparent,
          textColor: AppTheme.textPrimary,
        );
    }
  }

  BadgeDimensions _getBadgeDimensions() {
    switch (size) {
      case BadgeSize.small:
        return BadgeDimensions(
          horizontalPadding: AppTheme.spacingSm,
          verticalPadding: AppTheme.spacingXs,
          fontSize: 10,
          iconSize: 12,
          iconSpacing: AppTheme.spacingXs,
          borderRadius: AppTheme.radiusSm,
        );
      case BadgeSize.medium:
        return BadgeDimensions(
          horizontalPadding: AppTheme.spacingSm,
          verticalPadding: AppTheme.spacingXs,
          fontSize: 12,
          iconSize: 14,
          iconSpacing: AppTheme.spacingXs,
          borderRadius: AppTheme.radiusSm,
        );
      case BadgeSize.large:
        return BadgeDimensions(
          horizontalPadding: AppTheme.spacingMd,
          verticalPadding: AppTheme.spacingSm,
          fontSize: 14,
          iconSize: 16,
          iconSpacing: AppTheme.spacingSm,
          borderRadius: AppTheme.radiusMd,
        );
    }
  }
}

class BadgeColors {
  final Color backgroundColor;
  final Color textColor;

  BadgeColors({
    required this.backgroundColor,
    required this.textColor,
  });
}

class BadgeDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double borderRadius;

  BadgeDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.borderRadius,
  });
}

// Predefined status badges for common use cases
class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    BadgeVariant variant;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'paid':
        variant = BadgeVariant.success;
        icon = Icons.check_circle;
        break;
      case 'pending':
        variant = BadgeVariant.warning;
        icon = Icons.schedule;
        break;
      case 'overdue':
        variant = BadgeVariant.error;
        icon = Icons.warning;
        break;
      case 'cancelled':
        variant = BadgeVariant.secondary;
        icon = Icons.cancel;
        break;
      default:
        variant = BadgeVariant.info;
        icon = Icons.info;
    }

    return StatusBadge(
      text: status,
      variant: variant,
      icon: icon,
      size: BadgeSize.small,
    );
  }
}

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    BadgeVariant variant;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        variant = BadgeVariant.success;
        icon = Icons.check_circle;
        break;
      case 'pending':
        variant = BadgeVariant.warning;
        icon = Icons.schedule;
        break;
      case 'cancelled':
        variant = BadgeVariant.error;
        icon = Icons.cancel;
        break;
      case 'completed':
        variant = BadgeVariant.primary;
        icon = Icons.done_all;
        break;
      default:
        variant = BadgeVariant.info;
        icon = Icons.info;
    }

    return StatusBadge(
      text: status,
      variant: variant,
      icon: icon,
      size: BadgeSize.small,
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    BadgeVariant variant;
    IconData? icon;

    switch (priority.toLowerCase()) {
      case 'high':
        variant = BadgeVariant.error;
        icon = Icons.priority_high;
        break;
      case 'medium':
        variant = BadgeVariant.warning;
        icon = Icons.remove;
        break;
      case 'low':
        variant = BadgeVariant.info;
        icon = Icons.keyboard_arrow_down;
        break;
      default:
        variant = BadgeVariant.secondary;
        icon = Icons.info;
    }

    return StatusBadge(
      text: priority,
      variant: variant,
      icon: icon,
      size: BadgeSize.small,
    );
  }
}
