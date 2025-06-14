import 'package:flutter/material.dart';

class Table extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;

  const Table({
    super.key,
    required this.children,
    this.padding,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border ??
            Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class TableBody extends StatelessWidget {
  final List<Widget> children;

  const TableBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class TableCell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;

  const TableCell({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: backgroundColor, border: border),
      child: child,
    );
  }
}

class TableHead extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;

  const TableHead({super.key, required this.children, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ??
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
      child: Row(
        children: children.map((child) => Expanded(child: child)).toList(),
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;

  const TableHeader({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: backgroundColor, border: border),
      child: DefaultTextStyle(
        style: Theme.of(
          context,
        ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600),
        child: child,
      ),
    );
  }
}

class TableRow extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const TableRow({
    super.key,
    required this.children,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      color: backgroundColor,
      child: Row(
        children: children.map((child) => Expanded(child: child)).toList(),
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: row);
    }

    return row;
  }
}
