import 'package:flutter/material.dart';

class Select extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final String? placeholder;
  final bool disabled;
  final String? Function(String?)? validator;

  const Select({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.placeholder,
    this.disabled = false,
    this.validator,
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
        DropdownButtonFormField<String>(
          value: value != null && items.contains(value!) ? value : null,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: disabled ? null : onChanged,
          validator: validator,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          icon: Icon(
            Icons.expand_more,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
        ),
      ],
    );
  }
}

class SelectGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SelectGroup({
    super.key,
    this.label,
    required this.children,
    this.padding,
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
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class SelectItem extends StatelessWidget {
  final String value;
  final String text;
  final bool disabled;

  const SelectItem({
    super.key,
    required this.value,
    required this.text,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
