import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, link, destructive }

class Button extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool disabled;
  final Widget? prefix;
  final Widget? suffix;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const Button({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.disabled = false,
    this.prefix,
    this.suffix,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : assert(text != null || child != null);

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (disabled) return AppTheme.surfaceColor.withValues(alpha: 0.5);

      switch (variant) {
        case ButtonVariant.primary:
          return AppTheme.goldColor;
        case ButtonVariant.secondary:
          return AppTheme.surfaceColor;
        case ButtonVariant.outline:
        case ButtonVariant.ghost:
        case ButtonVariant.link:
          return Colors.transparent;
        case ButtonVariant.destructive:
          return AppTheme.errorColor;
      }
    }

    Color getTextColor() {
      if (disabled) return AppTheme.textMuted;

      switch (variant) {
        case ButtonVariant.primary:
          return Colors.black;
        case ButtonVariant.secondary:
          return AppTheme.textPrimary;
        case ButtonVariant.destructive:
          return Colors.white;
        case ButtonVariant.outline:
          return AppTheme.goldColor;
        case ButtonVariant.ghost:
        case ButtonVariant.link:
          return AppTheme.textPrimary;
      }
    }

    BorderSide? getBorder() {
      if (disabled) {
        return BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3));
      }

      switch (variant) {
        case ButtonVariant.outline:
          return const BorderSide(color: AppTheme.goldColor);
        default:
          return null;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (!disabled && !isLoading) ? onPressed : null,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        splashColor: getTextColor().withValues(alpha: 0.1),
        highlightColor: getTextColor().withValues(alpha: 0.05),
        child: Container(
          width: width,
          height: height ?? 44,
          constraints: const BoxConstraints(
            minHeight: 44, // Ensure minimum touch target size
            minWidth: 44,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
            border: getBorder() != null
                ? Border.fromBorderSide(getBorder()!)
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisSize:
                    width == null ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefix != null &&
                      !isLoading &&
                      constraints.maxWidth > 80) ...[
                    prefix!,
                    const SizedBox(width: AppTheme.spacingSm),
                  ],
                  if (isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(getTextColor()),
                      ),
                    ),
                    if (constraints.maxWidth > 60)
                      const SizedBox(width: AppTheme.spacingSm),
                  ],
                  Flexible(
                    child: DefaultTextStyle(
                      style: AppTheme.labelLarge.copyWith(
                        color: getTextColor(),
                        fontSize: constraints.maxWidth < 80 ? 12 : null,
                      ),
                      child: child ??
                          Text(
                            text!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                    ),
                  ),
                  if (suffix != null &&
                      !isLoading &&
                      constraints.maxWidth > 80) ...[
                    const SizedBox(width: AppTheme.spacingSm),
                    suffix!,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
