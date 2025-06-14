import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum CardVariant { default_, elevated, gold, outline }

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final CardVariant variant;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.variant = CardVariant.default_,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;

    switch (variant) {
      case CardVariant.elevated:
        decoration = AppTheme.cardDecorationElevated;
        break;
      case CardVariant.gold:
        decoration = AppTheme.cardDecorationGold;
        break;
      case CardVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        );
        break;
      case CardVariant.default_:
        decoration = AppTheme.cardDecoration;
        break;
    }

    if (backgroundColor != null) {
      decoration = decoration.copyWith(color: backgroundColor);
    }

    if (borderRadius != null) {
      decoration = decoration.copyWith(borderRadius: borderRadius);
    }

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      decoration: decoration,
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                ),
              ),
            )
          : child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

// Specialized card components
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      isLoading: isLoading,
      padding: EdgeInsets.zero, // Remove padding to maximize space
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Handle extremely small constraints
          if (constraints.maxWidth < 60 || constraints.maxHeight < 50) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 12,
                      color: iconColor ?? AppTheme.goldColor,
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }

          final isVerySmall =
              constraints.maxWidth < 100 || constraints.maxHeight < 80;
          final isSmall =
              constraints.maxWidth < 140 || constraints.maxHeight < 120;

          // Adjust sizes based on available space
          final iconSize = isVerySmall ? 14.0 : (isSmall ? 18.0 : 22.0);
          final valueSize = isVerySmall ? 12.0 : (isSmall ? 16.0 : 20.0);
          final labelSize = isVerySmall ? 8.0 : (isSmall ? 10.0 : 12.0);
          final padding = isVerySmall ? 4.0 : (isSmall ? 8.0 : 12.0);
          final iconPadding = isVerySmall ? 3.0 : (isSmall ? 6.0 : 8.0);
          final verticalSpacing = isVerySmall ? 2.0 : (isSmall ? 6.0 : 8.0);
          final smallSpacing = isVerySmall ? 1.0 : (isSmall ? 3.0 : 4.0);

          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with background
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.goldColor)
                          .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(isVerySmall ? 4.0 : 6.0),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? AppTheme.goldColor,
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing),

                // Value
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),

                SizedBox(height: smallSpacing),

                // Label
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: isVerySmall ? 1 : 2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppTheme.goldColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? AppTheme.goldColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  description,
                  style: AppTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  time,
                  style: AppTheme.labelSmall,
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color:
                      (iconColor ?? AppTheme.goldColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.goldColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: AppTheme.labelSmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
