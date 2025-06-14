import 'package:flutter/material.dart';

class Dialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool open;
  final VoidCallback? onClose;

  const Dialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    required this.open,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.shrink();

    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: content,
      actions: actions,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class DialogContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DialogContent({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding ?? EdgeInsets.zero, child: child);
  }
}

class DialogHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DialogHeader({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}

class DialogTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DialogTitle({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? Theme.of(context).textTheme.titleLarge);
  }
}

class DialogTrigger extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const DialogTrigger({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}
