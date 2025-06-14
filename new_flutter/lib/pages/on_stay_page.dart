import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/export_button.dart';
import 'package:new_flutter/models/on_stay.dart';
import 'package:new_flutter/services/on_stay_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class OnStayPage extends StatefulWidget {
  const OnStayPage({super.key});

  @override
  State<OnStayPage> createState() => _OnStayPageState();
}

class _OnStayPageState extends State<OnStayPage> with TickerProviderStateMixin {
  List<OnStay> _stays = [];
  bool _loading = true;
  String _selectedFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStays() async {
    debugPrint('🏨 Loading stays with filter: $_selectedFilter');
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      List<OnStay> stays;
      switch (_selectedFilter) {
        case 'upcoming':
          debugPrint('🏨 Fetching upcoming stays...');
          stays = await OnStayService.getUpcoming();
          break;
        case 'current':
          debugPrint('🏨 Fetching current stays...');
          stays = await OnStayService.getCurrent();
          break;
        case 'past':
          debugPrint('🏨 Fetching past stays...');
          stays = await OnStayService.getPast();
          break;
        default:
          debugPrint('🏨 Fetching all stays...');
          stays = await OnStayService.list();
      }

      debugPrint('🏨 Loaded ${stays.length} stays');
      for (var stay in stays) {
        debugPrint('🏨 Stay: ${stay.locationName} (${stay.id})');
      }

      if (mounted) {
        setState(() {
          _stays = stays;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('🏨 Error loading stays: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stays: $e')),
        );
      }
    }
  }

  void _editStay(OnStay stay) async {
    final result = await Navigator.pushNamed(
      context,
      '/new-on-stay',
      arguments: stay,
    );
    if (result == true && mounted) {
      _loadStays();
    }
  }

  void _showDeleteConfirmation(OnStay stay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Stay'),
          content: Text('Are you sure you want to delete "${stay.locationName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteStay(stay);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStay(OnStay stay) async {
    try {
      final success = await OnStayService.delete(stay.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Stay deleted successfully'
                : 'Failed to delete stay'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadStays();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting stay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/on-stay',
      title: 'On Stay',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.onStays,
          data: _stays,
          customFilename: 'on_stays_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/new-on-stay');
            if (result == true) {
              _loadStays(); // Refresh the list
            }
          },
        ),
      ],
      child: Column(
        children: [
          // Tab bar for filtering
          Container(
            color: Colors.grey[900],
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                switch (index) {
                  case 0:
                    _selectedFilter = 'all';
                    break;
                  case 1:
                    _selectedFilter = 'upcoming';
                    break;
                  case 2:
                    _selectedFilter = 'current';
                    break;
                  case 3:
                    _selectedFilter = 'past';
                    break;
                }
                _loadStays();
              },
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Current'),
                Tab(text: 'Past'),
              ],
              indicatorColor: AppTheme.goldColor,
              labelColor: AppTheme.goldColor,
              unselectedLabelColor: Colors.grey,
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _stays.isEmpty
                    ? _buildEmptyState()
                    : _buildStaysList(),
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
          Icon(
            Icons.hotel,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No stays found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first stay to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/new-on-stay');
              if (result == true) {
                _loadStays();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Stay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaysList() {
    return RefreshIndicator(
      onRefresh: _loadStays,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stays.length,
        itemBuilder: (context, index) {
          final stay = _stays[index];
          return _buildStayCard(stay);
        },
      ),
    );
  }

  Widget _buildStayCard(OnStay stay) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => _showStayDetails(stay),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with location, status, and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stay.locationName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildStatusChip(stay.status),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editStay(stay);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(stay);
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

              if (stay.stayType != null) ...[
                const SizedBox(height: 8),
                Text(
                  stay.stayType!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],

              if (stay.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        stay.address!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Date and time info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    stay.dateRange,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),

              if (stay.timeRange.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      stay.timeRange,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Cost and payment status
              Row(
                children: [
                  Text(
                    stay.formattedCost,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldColor,
                    ),
                  ),
                  const Spacer(),
                  _buildPaymentStatusChip(stay.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color color;
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        paymentStatus.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStayDetails(OnStay stay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          stay.locationName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stay.stayType != null) ...[
                _buildDetailRow('Type', stay.stayType!),
                const SizedBox(height: 8),
              ],
              if (stay.address != null) ...[
                _buildDetailRow('Address', stay.address!),
                const SizedBox(height: 8),
              ],
              _buildDetailRow('Dates', stay.dateRange),
              if (stay.timeRange.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Times', stay.timeRange),
              ],
              const SizedBox(height: 8),
              _buildDetailRow('Cost', stay.formattedCost),
              const SizedBox(height: 8),
              _buildDetailRow('Status', stay.status),
              const SizedBox(height: 8),
              _buildDetailRow('Payment', stay.paymentStatus),
              if (stay.contactName != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Contact', stay.contactName!),
              ],
              if (stay.contactPhone != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Phone', stay.contactPhone!),
              ],
              if (stay.contactEmail != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Email', stay.contactEmail!),
              ],
              if (stay.notes != null && stay.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Notes', stay.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.pushNamed(
                context,
                '/new-on-stay',
                arguments: stay,
              );
              if (result == true) {
                _loadStays(); // Refresh the list
              }
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
