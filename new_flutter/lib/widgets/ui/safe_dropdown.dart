import 'package:flutter/material.dart';

/// A safe dropdown widget that prevents assertion errors
class SafeDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final InputDecoration? decoration;

  const SafeDropdown({
    super.key,
    this.value,
    required this.items,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.decoration,
  });

  @override
  State<SafeDropdown> createState() => _SafeDropdownState();
}

class _SafeDropdownState extends State<SafeDropdown> {
  String? _currentValue;
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _updateCurrentValue();
  }

  @override
  void didUpdateWidget(SafeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      _updateCurrentValue();
    }
  }

  void _updateCurrentValue() {
    // Only set value if it exists in items, otherwise null
    _currentValue = widget.items.contains(widget.value) ? widget.value : null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isExpanded = false;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = item == _currentValue;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentValue = item;
                      });
                      widget.onChanged?.call(item);
                      _removeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[800] : null,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<String>(
        initialValue: _currentValue,
        validator: widget.validator,
        builder: (FormFieldState<String> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError 
                          ? Colors.red 
                          : _isExpanded 
                              ? Colors.blue 
                              : Colors.grey[600]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: widget.enabled ? null : Colors.grey[800],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentValue ?? widget.hintText ?? widget.labelText ?? 'Select an option',
                          style: TextStyle(
                            color: _currentValue != null 
                                ? Colors.white 
                                : Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A safe enum dropdown widget that prevents assertion errors
class SafeEnumDropdown<T extends Enum> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String? labelText;
  final String? hintText;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final String Function(T)? displayText;

  const SafeEnumDropdown({
    super.key,
    this.value,
    required this.items,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.displayText,
  });

  @override
  State<SafeEnumDropdown<T>> createState() => _SafeEnumDropdownState<T>();
}

class _SafeEnumDropdownState<T extends Enum> extends State<SafeEnumDropdown<T>> {
  T? _currentValue;
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _updateCurrentValue();
  }

  @override
  void didUpdateWidget(SafeEnumDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      _updateCurrentValue();
    }
  }

  void _updateCurrentValue() {
    // Only set value if it exists in items, otherwise null
    _currentValue = widget.items.contains(widget.value) ? widget.value : null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isExpanded = false;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  String _getDisplayText(T item) {
    if (widget.displayText != null) {
      return widget.displayText!(item);
    }
    return item.toString().split('.').last;
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = item == _currentValue;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentValue = item;
                      });
                      widget.onChanged?.call(item);
                      _removeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[800] : null,
                      ),
                      child: Text(
                        _getDisplayText(item),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<T>(
        initialValue: _currentValue,
        validator: widget.validator,
        builder: (FormFieldState<T> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError
                          ? Colors.red
                          : _isExpanded
                              ? Colors.blue
                              : Colors.grey[600]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: widget.enabled ? null : Colors.grey[800],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentValue != null
                              ? _getDisplayText(_currentValue!)
                              : widget.hintText ?? widget.labelText ?? 'Select an option',
                          style: TextStyle(
                            color: _currentValue != null
                                ? Colors.white
                                : Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
