import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../responsive_layout.dart';

class SearchFilterBar extends StatelessWidget {
  final String? searchHint;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final List<FilterOption>? filterOptions;
  final String? selectedFilter;
  final ValueChanged<String?>? onFilterChanged;
  final List<SortOption>? sortOptions;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;
  final Widget? trailing;
  final bool showViewToggle;
  final bool isGridView;
  final VoidCallback? onViewToggle;

  const SearchFilterBar({
    super.key,
    this.searchHint = 'Search...',
    required this.searchValue,
    required this.onSearchChanged,
    this.filterOptions,
    this.selectedFilter,
    this.onFilterChanged,
    this.sortOptions,
    this.selectedSort,
    this.onSortChanged,
    this.trailing,
    this.showViewToggle = false,
    this.isGridView = true,
    this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveBreakpoints.isSmallScreen(context);

    if (isSmallScreen) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 3,
          child: _buildSearchField(),
        ),

        SizedBox(width: ResponsiveSpacing.small(context)),

        // Filter Dropdown
        if (filterOptions != null && filterOptions!.isNotEmpty) ...[
          _buildFilterDropdown(),
          SizedBox(width: ResponsiveSpacing.small(context)),
        ],

        // Sort Dropdown
        if (sortOptions != null && sortOptions!.isNotEmpty) ...[
          _buildSortDropdown(),
          SizedBox(width: ResponsiveSpacing.small(context)),
        ],

        // View Toggle
        if (showViewToggle) ...[
          _buildViewToggle(),
          SizedBox(width: ResponsiveSpacing.small(context)),
        ],

        // Trailing Widget
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Search Field
        _buildSearchField(),

        const SizedBox(height: AppTheme.spacingSm),

        // Filters Row
        Row(
          children: [
            // Filter Dropdown
            if (filterOptions != null && filterOptions!.isNotEmpty) ...[
              Expanded(child: _buildFilterDropdown()),
              const SizedBox(width: AppTheme.spacingSm),
            ],

            // Sort Dropdown
            if (sortOptions != null && sortOptions!.isNotEmpty) ...[
              Expanded(child: _buildSortDropdown()),
              const SizedBox(width: AppTheme.spacingSm),
            ],

            // View Toggle
            if (showViewToggle) ...[
              _buildViewToggle(),
              const SizedBox(width: AppTheme.spacingSm),
            ],

            // Trailing Widget
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: AppTheme.bodyMedium,
        // Add cursor styling for better visibility
        cursorColor: AppTheme.goldColor,
        cursorWidth: 2.0,
        showCursor: true,
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter != null && filterOptions!.any((option) => option.value == selectedFilter)
              ? selectedFilter
              : null,
          hint: const Text('Filter', style: AppTheme.bodyMedium),
          icon: const Icon(Icons.filter_list, color: AppTheme.textMuted),
          dropdownColor: AppTheme.surfaceColor,
          style: AppTheme.bodyMedium,
          onChanged: onFilterChanged,
          items: filterOptions!.map((option) {
            return DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort != null && sortOptions!.any((option) => option.value == selectedSort)
              ? selectedSort
              : null,
          hint: const Text('Sort', style: AppTheme.bodyMedium),
          icon: const Icon(Icons.sort, color: AppTheme.textMuted),
          dropdownColor: AppTheme.surfaceColor,
          style: AppTheme.bodyMedium,
          onChanged: onSortChanged,
          items: sortOptions!.map((option) {
            return DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: IconButton(
        onPressed: onViewToggle,
        icon: Icon(
          isGridView ? Icons.view_list : Icons.grid_view,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class FilterOption {
  final String value;
  final String label;

  const FilterOption({
    required this.value,
    required this.label,
  });
}

class SortOption {
  final String value;
  final String label;

  const SortOption({
    required this.value,
    required this.label,
  });
}
