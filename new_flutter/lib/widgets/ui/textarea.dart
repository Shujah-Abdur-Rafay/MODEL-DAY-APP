import 'package:flutter/material.dart';

class Textarea extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  const Textarea({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.maxLines = 5,
    this.minLines = 3,
    this.readOnly = false,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          readOnly: readOnly,
          validator: validator,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          // Add cursor styling for better visibility
          cursorColor: const Color(0xFFD4AF37), // Gold color
          cursorWidth: 2.0,
          showCursor: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
