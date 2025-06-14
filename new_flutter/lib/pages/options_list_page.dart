import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/services/events_service.dart';
import 'package:new_flutter/widgets/export_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class OptionsListPage extends StatefulWidget {
  const OptionsListPage({super.key});

  @override
  State<OptionsListPage> createState() => _OptionsListPageState();
}

class _OptionsListPageState extends State<OptionsListPage> {
  List<Event> _options = [];
  bool _isLoading = true;
  String? _error;
  final EventsService _eventsService = EventsService();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get all events and filter for option types
      final allEvents = await _eventsService.getEvents();
      final options = allEvents.where((event) =>
        event.type == EventType.option || event.type == EventType.directOption
      ).toList();

      // Sort by date (newest first)
      options.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

      if (mounted) {
        setState(() {
          _options = options;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading options: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteOption(String optionId) async {
    try {
      final success = await _eventsService.deleteEvent(optionId);
      if (success) {
        await _loadOptions(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Option deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete option');
      }
    } catch (e) {
      debugPrint('Error deleting option: $e');
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

  void _showDeleteConfirmation(Event option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Option',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${option.clientName ?? 'this option'}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (option.id != null) {
                _deleteOption(option.id!);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(Event option, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!.withValues(alpha: 0.8),
            Colors.grey[900]!.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option.type == EventType.directOption ? Icons.arrow_forward : Icons.schedule,
                  color: AppTheme.goldColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.clientName ?? 'No client name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[800],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.pushNamed(
                        context,
                        '/new-option',
                        arguments: {'event': option},
                      ).then((_) => _loadOptions());
                      break;
                    case 'delete':
                      _showDeleteConfirmation(option);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Option details
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                option.date != null
                    ? DateFormat('MMM d, yyyy').format(option.date!)
                    : 'No date set',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(width: 24),
              Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                option.startTime ?? 'No time set',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),

          if (option.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.location!,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ],

          if (option.dayRate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  '${option.dayRate} ${option.currency ?? 'USD'}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(option),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getStatusText(option),
              style: TextStyle(
                color: _getStatusTextColor(option),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2);
  }

  Color _getStatusColor(Event option) {
    // Use optionStatus for options, fallback to general status
    final status = option.optionStatus ?? option.status;
    if (status == null) return Colors.grey.withValues(alpha: 0.2);

    switch (status.toString().split('.').last.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return Colors.green.withValues(alpha: 0.2);
      case 'pending':
      case 'scheduled':
        return Colors.orange.withValues(alpha: 0.2);
      case 'canceled':
      case 'declined':
      case 'clientcanceled':
      case 'ideclined':
        return Colors.red.withValues(alpha: 0.2);
      case 'postponed':
        return Colors.blue.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Color _getStatusTextColor(Event option) {
    final status = option.optionStatus ?? option.status;
    if (status == null) return Colors.grey;

    switch (status.toString().split('.').last.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'scheduled':
        return Colors.orange;
      case 'canceled':
      case 'declined':
      case 'clientcanceled':
      case 'ideclined':
        return Colors.red;
      case 'postponed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(Event option) {
    // Use optionStatus for options, fallback to general status
    final status = option.optionStatus ?? option.status;
    if (status == null) return 'Unknown';

    // Convert enum to display text
    final statusString = status.toString().split('.').last;
    switch (statusString.toLowerCase()) {
      case 'clientcanceled':
        return 'Client Canceled';
      case 'ideclined':
        return 'I Declined';
      default:
        return statusString[0].toUpperCase() + statusString.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/options',
      title: 'Options',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.events,
          data: _options,
          customFilename: 'options_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/new-option').then((_) => _loadOptions());
          },
          tooltip: 'Add Option',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadOptions,
          tooltip: 'Refresh',
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading options',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOptions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _options.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No options yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first option to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/new-option')
                                  .then((_) => _loadOptions());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Option'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldColor,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionCard(_options[index], index);
                      },
                    ),
    );
  }
}
