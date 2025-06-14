import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (action != null) action!,
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
