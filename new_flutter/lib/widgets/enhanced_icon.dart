import 'package:flutter/material.dart';

/// Enhanced icon widget that ensures proper rendering across all platforms
class EnhancedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const EnhancedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Icon(
          icon,
          size: size ?? 24,
          color: color ?? Colors.white,
          semanticLabel: semanticLabel,
          textDirection: textDirection ?? TextDirection.ltr,
        ),
      ),
    );
  }
}

/// Enhanced icon button that ensures proper rendering and touch targets
class EnhancedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final double? splashRadius;

  const EnhancedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.color,
    this.semanticLabel,
    this.padding,
    this.splashRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: EnhancedIcon(
            icon,
            size: size ?? 20,
            color: color ?? Colors.white,
            semanticLabel: semanticLabel,
          ),
          onPressed: onPressed,
          padding: padding ?? EdgeInsets.zero,
          splashRadius: splashRadius ?? 20,
        ),
      ),
    );
  }
}
