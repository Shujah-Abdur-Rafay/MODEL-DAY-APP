import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/direct_booking.dart';
import 'package:new_flutter/services/direct_bookings_service.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedDirectBookingsPage extends StatefulWidget {
  const EnhancedDirectBookingsPage({super.key});

  @override
  State<EnhancedDirectBookingsPage> createState() =>
      _EnhancedDirectBookingsPageState();
}

class _EnhancedDirectBookingsPageState
    extends State<EnhancedDirectBookingsPage> {
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

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/direct-bookings',
      title: 'Direct Bookings',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-direct-booking'),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;

          return Column(
            children: [
              // Header
              _buildHeader(isSmallScreen),
              const SizedBox(height: 24),

              // Search and Filters
              _buildSearchAndFilters(isSmallScreen),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBookings.isEmpty
                        ? _buildEmptyState(isSmallScreen)
                        : _buildBookingsList(isSmallScreen),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct Bookings',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track all your direct bookings and earnings',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/new-direct-booking');
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(isSmallScreen ? 'Add' : 'Add New Direct Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSearchAndFilters(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 0),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 3,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3E3E3E)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search bookings...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Sort Button
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3E3E3E)),
            ),
            child: PopupMenuButton<String>(
              color: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF3E3E3E)),
              ),
              icon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Sort', style: TextStyle(color: Colors.white)),
                ],
              ),
              onSelected: (value) {
                setState(() => _sortOrder = value);
                _applyFilters();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date-desc',
                  child: Text('Newest First',
                      style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'date-asc',
                  child: Text('Oldest First',
                      style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'client-asc',
                  child: Text('Client (A-Z)',
                      style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'client-desc',
                  child: Text('Client (Z-A)',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Grid/List Toggle
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3E3E3E)),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: isSmallScreen ? 80 : 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No direct bookings found',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, '/new-direct-booking'),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add New Direct Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 32,
                vertical: isSmallScreen ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildBookingsList(bool isSmallScreen) {
    if (_isGridView && !isSmallScreen) {
      return _buildGridView();
    } else {
      return _buildListView(isSmallScreen);
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) =>
          _buildBookingCard(_filteredBookings[index], index),
    );
  }

  Widget _buildListView(bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) =>
          _buildBookingListItem(_filteredBookings[index], index, isSmallScreen),
    );
  }

  Widget _buildBookingCard(DirectBooking booking, int index) {
    final finalAmount = _calculateFinalAmount(booking);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with client name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.clientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
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
                            Icon(Icons.edit, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Colors.white)),
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
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Booking type and location
              if (booking.bookingType != null)
                Text(
                  booking.bookingType!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
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
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Date
              if (booking.date != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(booking.date!),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Amount and payment status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getCurrencySymbol(booking.currency)}${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldColor,
                    ),
                  ),
                  _buildPaymentStatusChip(booking.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildBookingListItem(
      DirectBooking booking, int index, bool isSmallScreen) {
    final finalAmount = _calculateFinalAmount(booking);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.clientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
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
                                  Icon(Icons.edit, size: 16, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Edit', style: TextStyle(color: Colors.white)),
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
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (booking.bookingType != null)
                      Text(
                        booking.bookingType!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    if (booking.date != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(booking.date!),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),

              // Amount and payment status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getCurrencySymbol(booking.currency)}${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentStatusChip(booking.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 50 * index));
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

  Widget _buildStatusChip(String? status) {
    Color color;
    String displayText;

    switch (status?.toLowerCase()) {
      case 'scheduled':
        color = Colors.blue;
        displayText = 'Scheduled';
        break;
      case 'in_progress':
        color = Colors.orange;
        displayText = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        displayText = 'Completed';
        break;
      case 'canceled':
        color = Colors.red;
        displayText = 'Canceled';
        break;
      default:
        color = Colors.grey;
        displayText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String? paymentStatus) {
    Color color;
    String displayText;

    switch (paymentStatus?.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        displayText = 'Paid';
        break;
      case 'partial':
        color = Colors.orange;
        displayText = 'Partial';
        break;
      case 'unpaid':
        color = Colors.red;
        displayText = 'Unpaid';
        break;
      default:
        color = Colors.grey;
        displayText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
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
}
