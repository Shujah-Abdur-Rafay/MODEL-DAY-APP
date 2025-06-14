import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Input extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final String? hintText;
  final bool showPasswordToggle;

  const Input({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.hintText,
    this.showPasswordToggle = false,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon = widget.suffix;

    // Add password toggle if enabled
    if (widget.showPasswordToggle && widget.keyboardType == TextInputType.visiblePassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.goldColor.withValues(alpha: 0.7),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        splashRadius: 20,
        padding: EdgeInsets.zero,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: Text(
              widget.label!,
              style: AppTheme.labelLarge,
            ),
          ),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          decoration: AppTheme.textFieldDecoration.copyWith(
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixIcon,
            hintText: widget.hintText ?? widget.placeholder,
            hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
            // Override autofill styling
            fillColor: AppTheme.surfaceColor,
            filled: true,
          ),
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary, // Ensure text is white
          ),
          // Add cursor styling for better visibility
          cursorColor: AppTheme.goldColor,
          cursorWidth: 2.0,
          showCursor: true,
          // Disable browser autofill styling
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }
}
