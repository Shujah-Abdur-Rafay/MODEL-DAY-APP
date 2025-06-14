import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/export_button.dart';
import 'package:new_flutter/models/direct_booking.dart';
import 'package:new_flutter/services/direct_bookings_service.dart';

class DirectBookingsPage extends StatefulWidget {
  const DirectBookingsPage({super.key});

  @override
  State<DirectBookingsPage> createState() => _DirectBookingsPageState();
}

class _DirectBookingsPageState extends State<DirectBookingsPage> {
  List<DirectBooking> _bookings = [];
  List<DirectBooking> _filteredBookings = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortOrder = 'date-desc';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final bookings = await DirectBookingsService.list();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _filteredBookings = bookings;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBookings = _bookings.where((booking) {
        final searchLower = _searchQuery.toLowerCase();
        return booking.clientName.toLowerCase().contains(searchLower) ||
            (booking.bookingType?.toLowerCase().contains(searchLower) ??
                false) ||
            (booking.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      // Apply sorting
      _filteredBookings.sort((a, b) {
        switch (_sortOrder) {
          case 'date-asc':
            return (a.date ?? DateTime(1900))
                .compareTo(b.date ?? DateTime(1900));
          case 'date-desc':
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
          case 'client-asc':
            return a.clientName.compareTo(b.clientName);
          case 'client-desc':
            return b.clientName.compareTo(a.clientName);
          default:
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
        }
      });
    });
  }

  void _onSearchChanged(String query) {
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

  double _calculateFinalAmount(DirectBooking booking) {
    final baseAmount = booking.rate ?? 0;
    final extraHours = double.tryParse(booking.extraHours ?? '0') ?? 0;
    final additionalFees = double.tryParse(booking.additionalFees ?? '0') ?? 0;
    final agencyFeePercentage =
        double.tryParse(booking.agencyFeePercentage ?? '0') ?? 0;
    final taxPercentage = double.tryParse(booking.taxPercentage ?? '0') ?? 0;

    final extraHoursAmount = extraHours * (baseAmount / 8);
    final totalBeforeDeductions =
        baseAmount + extraHoursAmount + additionalFees;
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
          child: _filteredBookings.isEmpty
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
                hintText: 'Search bookings...',
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
              setState(() => _sortOrder = value);
              _applyFilters();
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
          const Icon(Icons.event_note, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No direct bookings found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, '/new-direct-booking'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Direct Booking'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) =>
          _buildBookingCard(_filteredBookings[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) =>
          _buildBookingListItem(_filteredBookings[index]),
    );
  }

  Widget _buildBookingCard(DirectBooking booking) {
    final finalAmount = _calculateFinalAmount(booking);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
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
                      booking.clientName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editBooking(booking);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(booking);
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
              booking.bookingType ?? 'No Type',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (booking.date != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(booking.date!),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (booking.location != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.location!,
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
                  '${_getCurrencySymbol(booking.currency)}${finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                _buildPaymentStatusChip(booking.paymentStatus),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBookingListItem(DirectBooking booking) {
    final finalAmount = _calculateFinalAmount(booking);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(booking.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.bookingType ?? 'No Type'),
            if (booking.date != null)
              Text(DateFormat('MMM d, yyyy').format(booking.date!)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_getCurrencySymbol(booking.currency)}${finalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildStatusChip(booking.status),
          ],
        ),
        onTap: () => _editBooking(booking),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      case 'completed':
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

  void _showBookingDetails(DirectBooking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(booking.clientName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (booking.bookingType != null) ...[
                  Text('Type: ${booking.bookingType}'),
                  const SizedBox(height: 8),
                ],
                if (booking.date != null) ...[
                  Text('Date: ${DateFormat('MMM d, yyyy').format(booking.date!)}'),
                  const SizedBox(height: 8),
                ],
                if (booking.location != null) ...[
                  Text('Location: ${booking.location}'),
                  const SizedBox(height: 8),
                ],
                if (booking.rate != null) ...[
                  Text('Rate: ${_getCurrencySymbol(booking.currency)}${booking.rate}'),
                  const SizedBox(height: 8),
                ],
                Text('Status: ${booking.status ?? 'Unknown'}'),
                const SizedBox(height: 8),
                Text('Payment: ${booking.paymentStatus ?? 'Unknown'}'),
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
                _editBooking(booking);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _editBooking(DirectBooking booking) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-direct-booking',
      arguments: booking,
    );
    if (result == true && mounted) {
      _loadBookings();
    }
  }

  void _showDeleteConfirmation(DirectBooking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: Text('Are you sure you want to delete "${booking.clientName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteBooking(booking);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking(DirectBooking booking) async {
    if (booking.id == null) return;

    try {
      final success = await DirectBookingsService.delete(booking.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Booking deleted successfully'
                : 'Failed to delete booking'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadBookings();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/direct-bookings',
      title: 'Direct Bookings',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.directBookings,
          data: _bookings,
          customFilename: 'direct_bookings_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-direct-booking'),
        ),
      ],
      child: _isLoading ? _buildLoadingWidget() : _buildContent(),
    );
  }
}
