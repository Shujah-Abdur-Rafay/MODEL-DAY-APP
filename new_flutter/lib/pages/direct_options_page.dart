import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/services/events_service.dart';
import 'package:new_flutter/widgets/export_button.dart';

class DirectOptionsPage extends StatefulWidget {
  const DirectOptionsPage({super.key});

  @override
  State<DirectOptionsPage> createState() => _DirectOptionsPageState();
}

class _DirectOptionsPageState extends State<DirectOptionsPage> {
  List<Event> _options = [];
  List<Event> _filteredOptions = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortOrder = 'date-desc';
  final TextEditingController _searchController = TextEditingController();
  final EventsService _eventsService = EventsService();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      debugPrint('🔍 DirectOptionsPage._loadOptions() - Loading direct options');

      // Get all events and filter for direct option types
      final allEvents = await _eventsService.getEvents();
      final options = allEvents.where((event) =>
        event.type == EventType.directOption
      ).toList();

      debugPrint('✅ DirectOptionsPage._loadOptions() - Found ${options.length} direct options');

      // Sort by date (newest first)
      options.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

      if (!mounted) return;
      setState(() {
        _options = options;
        _filteredOptions = options;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      debugPrint('❌ DirectOptionsPage._loadOptions() - Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading options: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredOptions = _options.where((option) {
        final searchLower = _searchQuery.toLowerCase();
        return (option.clientName?.toLowerCase().contains(searchLower) ?? false) ||
            (option.additionalData?['option_type']?.toLowerCase().contains(searchLower) ?? false) ||
            (option.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      // Apply sorting
      _filteredOptions.sort((a, b) {
        switch (_sortOrder) {
          case 'date-asc':
            return (a.date ?? DateTime(1900))
                .compareTo(b.date ?? DateTime(1900));
          case 'date-desc':
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
          case 'client-asc':
            return (a.clientName ?? '').compareTo(b.clientName ?? '');
          case 'client-desc':
            return (b.clientName ?? '').compareTo(a.clientName ?? '');
          default:
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
        }
      });
    });
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'EUR':
        return '€';
      case 'PLN':
        return 'zł';
      case 'ILS':
        return '₪';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'GBP':
        return '£';
      case 'USD':
      default:
        return '\$';
    }
  }

  double _calculateFinalAmount(Event option) {
    final baseAmount = option.dayRate ?? 0;
    final extraHours = double.tryParse(option.additionalData?['extra_hours']?.toString() ?? '0') ?? 0;
    final additionalFees = double.tryParse(option.additionalData?['additional_fees']?.toString() ?? '0') ?? 0;
    final agencyFeePercentage = double.tryParse(option.additionalData?['agency_fee']?.toString() ?? '0') ?? 0;
    final taxPercentage = double.tryParse(option.additionalData?['tax_percentage']?.toString() ?? '0') ?? 0;

    final extraHoursAmount = extraHours * (baseAmount / 8);
    final totalBeforeDeductions = baseAmount + extraHoursAmount + additionalFees;
    final agencyFee = (totalBeforeDeductions * agencyFeePercentage) / 100;
    final taxAmount = (totalBeforeDeductions * taxPercentage) / 100;
    final finalAmount = totalBeforeDeductions - agencyFee - taxAmount;

    return finalAmount;
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredOptions.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search options...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (mounted) {
                setState(() => _sortOrder = value);
                _applyFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'date-desc', child: Text('Newest First')),
              const PopupMenuItem(
                  value: 'date-asc', child: Text('Oldest First')),
              const PopupMenuItem(
                  value: 'client-asc', child: Text('Client (A-Z)')),
              const PopupMenuItem(
                  value: 'client-desc', child: Text('Client (Z-A)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No direct options found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first direct option to get started',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/new-direct-option');
              if (result == true && mounted) {
                _loadOptions();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Direct Option'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) crossAxisCount = 2;
        if (constraints.maxWidth > 900) crossAxisCount = 3;
        if (constraints.maxWidth > 1200) crossAxisCount = 4;

        return GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredOptions.length,
          itemBuilder: (context, index) =>
              _buildOptionCard(_filteredOptions[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) =>
          _buildOptionListItem(_filteredOptions[index]),
    );
  }

  Widget _buildOptionCard(Event option) {
    final finalAmount = _calculateFinalAmount(option);
    final optionType = option.additionalData?['option_type'] ?? 'No Type';
    final status = option.status?.toString().split('.').last ?? 'unknown';
    final paymentStatus = option.paymentStatus?.toString().split('.').last ?? 'unknown';

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showOptionDetails(option),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      option.clientName ?? 'No Client',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(status),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editOption(option);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(option);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              optionType,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (option.date != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(option.date!),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (option.location != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option.location!,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getCurrencySymbol(option.currency)}${finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                _buildPaymentStatusChip(paymentStatus),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildOptionListItem(Event option) {
    final finalAmount = _calculateFinalAmount(option);
    final optionType = option.additionalData?['option_type'] ?? 'No Type';
    final status = option.status?.toString().split('.').last ?? 'unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(option.clientName ?? 'No Client'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(optionType),
            if (option.date != null)
              Text(DateFormat('MMM d, yyyy').format(option.date!)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_getCurrencySymbol(option.currency)}${finalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildStatusChip(status),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          '/new-direct-option',
          arguments: {'event': option},
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'option':
        color = Colors.blue;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaymentStatusChip(String? paymentStatus) {
    Color color;
    switch (paymentStatus) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        paymentStatus?.toUpperCase() ?? 'UNKNOWN',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showOptionDetails(Event option) {
    final optionType = option.additionalData?['option_type'];
    final status = option.status?.toString().split('.').last ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(option.clientName ?? 'No Client'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (optionType != null) ...[
                  Text('Type: $optionType'),
                  const SizedBox(height: 8),
                ],
                if (option.date != null) ...[
                  Text('Date: ${DateFormat('MMM d, yyyy').format(option.date!)}'),
                  const SizedBox(height: 8),
                ],
                if (option.location != null) ...[
                  Text('Location: ${option.location}'),
                  const SizedBox(height: 8),
                ],
                if (option.dayRate != null) ...[
                  Text('Rate: ${_getCurrencySymbol(option.currency)}${option.dayRate}'),
                  const SizedBox(height: 8),
                ],
                Text('Status: $status'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editOption(option);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _editOption(Event option) async {
    final result = await Navigator.pushNamed(
      context,
      '/new-direct-option',
      arguments: {'event': option},
    );
    if (result == true && mounted) {
      _loadOptions();
    }
  }

  void _showDeleteConfirmation(Event option) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Option'),
          content: Text('Are you sure you want to delete "${option.clientName ?? 'this option'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteOption(option);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOption(Event option) async {
    if (option.id == null) return;

    try {
      final success = await _eventsService.deleteEvent(option.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Option deleted successfully'
                : 'Failed to delete option'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadOptions();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting option: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/direct-options',
      title: 'Direct Options',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.events,
          data: _options,
          customFilename: 'direct_options_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
          tooltip: 'Toggle View',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOptions,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-direct-option'),
          tooltip: 'Add Direct Option',
        ),
      ],
      child: _isLoading ? _buildLoadingWidget() : _buildContent(),
    );
  }
}
