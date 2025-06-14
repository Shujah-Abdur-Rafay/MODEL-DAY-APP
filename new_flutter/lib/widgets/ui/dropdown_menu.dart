import 'package:flutter/material.dart';

class DropdownMenu extends StatefulWidget {
  final Widget trigger;
  final List<Widget> children;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const DropdownMenu({
    super.key,
    required this.trigger,
    required this.children,
    this.width,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: widget.width ?? size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      widget.padding ?? const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ??
                        Theme.of(context).colorScheme.surface,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(8),
                    border: widget.border ??
                        Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleDropdown, child: widget.trigger),
    );
  }
}

class DropdownMenuContent extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const DropdownMenuContent({super.key, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class DropdownMenuItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool disabled;

  const DropdownMenuItem({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: disabled
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.onSurface,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class DropdownMenuLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  const DropdownMenuLabel({
    super.key,
    required this.text,
    this.style,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: style ??
            Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
      ),
    );
  }
}

class DropdownMenuSeparator extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const DropdownMenuSeparator({super.key, this.margin, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color:
          color ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    );
  }
}
