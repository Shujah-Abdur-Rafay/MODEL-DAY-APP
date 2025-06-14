import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/casting.dart';
import '../models/test.dart';
import '../models/event.dart';
import '../services/jobs_service.dart';
import '../services/events_service.dart';
import '../services/castings_service.dart';
import '../services/tests_service.dart';
import '../widgets/app_layout.dart';

import '../widgets/ui/badge.dart' as ui;
import '../widgets/ui/card.dart' as ui;
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _activities = [];
  String _searchTerm = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _sortBy = 'date';
  final bool _ascending = false;

  final List<String> _types = [
    'all',
    'option',
    'job',
    'direct-option',
    'direct-booking',
    'casting',
    'on-stay',
    'test',
    'polaroids',
    'meeting',
    'ai-jobs',
    'other'
  ];
  final List<String> _statuses = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];
  final List<String> _sortOptions = ['date', 'type', 'status'];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Load all types of activities including unified events
      final futures = await Future.wait([
        JobsService.list(),
        Casting.list(),
        Test.list(),
        EventsService().getEvents(), // Add unified events
      ]);

      final jobs = futures[0] as List<Job>;
      final castings = futures[1] as List<Casting>;
      final tests = futures[2] as List<Test>;
      final events = futures[3] as List<Event>;

      final activities = <dynamic>[...jobs, ...castings, ...tests, ...events];

      // Sort by date with better error handling
      activities.sort((a, b) {
        try {
          DateTime? aDate;
          DateTime? bDate;

          if (a is Job) {
            aDate = DateTime.tryParse(a.date);
          } else if (a is Casting) {
            aDate = a.date;
          } else if (a is Test) {
            aDate = a.date;
          } else if (a is Event) {
            aDate = a.date;
          }

          if (b is Job) {
            bDate = DateTime.tryParse(b.date);
          } else if (b is Casting) {
            bDate = b.date;
          } else if (b is Test) {
            bDate = b.date;
          } else if (b is Event) {
            bDate = b.date;
          }

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return bDate.compareTo(aDate); // Most recent first
        } catch (e) {
          debugPrint('Error sorting activities: $e');
          return 0;
        }
      });

      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading activities: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load activities: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredActivities {
    return _activities.where((activity) {
      // Type filter
      if (_typeFilter != 'all') {
        if (_typeFilter == 'job' && activity is! Job && !(activity is Event && activity.type == EventType.job)) return false;
        if (_typeFilter == 'casting' && activity is! Casting && !(activity is Event && activity.type == EventType.casting)) return false;
        if (_typeFilter == 'test' && activity is! Test && !(activity is Event && activity.type == EventType.test)) return false;
        if (_typeFilter == 'option' && !(activity is Event && activity.type == EventType.option)) return false;
        if (_typeFilter == 'direct-option' && !(activity is Event && activity.type == EventType.directOption)) return false;
        if (_typeFilter == 'direct-booking' && !(activity is Event && activity.type == EventType.directBooking)) return false;
        if (_typeFilter == 'on-stay' && !(activity is Event && activity.type == EventType.onStay)) return false;
        if (_typeFilter == 'polaroids' && !(activity is Event && activity.type == EventType.polaroids)) return false;
        if (_typeFilter == 'meeting' && !(activity is Event && activity.type == EventType.meeting)) return false;
        if (_typeFilter == 'other' && !(activity is Event && activity.type == EventType.other)) return false;
      }

      // Status filter
      if (_statusFilter != 'all') {
        String? activityStatus;
        if (activity is Job) {
          activityStatus = 'pending';
        } else if (activity is Event) {
          activityStatus = activity.status?.toString().split('.').last ?? 'pending';
        } else {
          activityStatus = activity.status;
        }
        if (activityStatus != _statusFilter) {
          return false;
        }
      }

      // Search
      final searchLower = _searchTerm.toLowerCase();
      if (searchLower.isNotEmpty) {
        String title = '';
        String description = '';
        String location = '';

        if (activity is Job) {
          title = activity.clientName.toLowerCase();
          description = activity.notes?.toLowerCase() ?? '';
          location = activity.location.toLowerCase();
        } else if (activity is Event) {
          title = activity.clientName?.toLowerCase() ?? '';
          description = activity.notes?.toLowerCase() ?? '';
          location = activity.location?.toLowerCase() ?? '';
        } else if (activity is Casting) {
          title = activity.title.toLowerCase();
          description = activity.description?.toLowerCase() ?? '';
          location = activity.location?.toLowerCase() ?? '';
        } else if (activity is Test) {
          title = activity.title.toLowerCase();
          description = activity.description?.toLowerCase() ?? '';
          location = activity.location?.toLowerCase() ?? '';
        } else {
          // Fallback for other types
          title = activity.toString().toLowerCase();
          description = '';
          location = '';
        }

        return title.contains(searchLower) ||
            description.contains(searchLower) ||
            location.contains(searchLower);
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'date') {
          try {
            DateTime? aDate;
            DateTime? bDate;

            if (a is Job) {
              aDate = DateTime.tryParse(a.date);
            } else if (a is Event) {
              aDate = a.date;
            } else {
              aDate = a.date;
            }

            if (b is Job) {
              bDate = DateTime.tryParse(b.date);
            } else if (b is Event) {
              bDate = b.date;
            } else {
              bDate = b.date;
            }

            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;

            return _ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          } catch (e) {
            return 0;
          }
        } else if (_sortBy == 'type') {
          String aType = '';
          String bType = '';

          if (a is Job) {
            aType = 'job';
          } else if (a is Event) {
            aType = a.type.toString().split('.').last;
          } else if (a is Casting) {
            aType = 'casting';
          } else {
            aType = 'test';
          }

          if (b is Job) {
            bType = 'job';
          } else if (b is Event) {
            bType = b.type.toString().split('.').last;
          } else if (b is Casting) {
            bType = 'casting';
          } else {
            bType = 'test';
          }

          return _ascending ? aType.compareTo(bType) : bType.compareTo(aType);
        } else if (_sortBy == 'status') {
          String aStatus = '';
          String bStatus = '';

          if (a is Job) {
            aStatus = 'pending';
          } else if (a is Event) {
            aStatus = a.status?.toString().split('.').last ?? 'pending';
          } else {
            aStatus = a.status ?? 'pending';
          }

          if (b is Job) {
            bStatus = 'pending';
          } else if (b is Event) {
            bStatus = b.status?.toString().split('.').last ?? 'pending';
          } else {
            bStatus = b.status ?? 'pending';
          }

          return _ascending
              ? aStatus.compareTo(bStatus)
              : bStatus.compareTo(aStatus);
        }
        return 0;
      });
  }

  Color _getTypeColor(dynamic activity) {
    if (activity is Job) return Colors.blue;
    if (activity is Casting) return Colors.purple;
    if (activity is Test) return Colors.orange;
    if (activity is Event) {
      switch (activity.type) {
        case EventType.option:
          return Colors.cyan;
        case EventType.job:
          return Colors.blue;
        case EventType.directOption:
          return Colors.teal;
        case EventType.directBooking:
          return Colors.green;
        case EventType.casting:
          return Colors.purple;
        case EventType.onStay:
          return Colors.orange;
        case EventType.test:
          return Colors.amber;
        case EventType.polaroids:
          return Colors.pink;
        case EventType.meeting:
          return Colors.indigo;
        case EventType.other:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  String _getTypeName(dynamic activity) {
    if (activity is Job) return 'Job';
    if (activity is Casting) return 'Casting';
    if (activity is Test) return 'Test';
    if (activity is Event) {
      return activity.type.displayName;
    }
    return 'Activity';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF9C3); // yellow-100
      case 'confirmed':
        return const Color(0xFFDBEAFE); // blue-100
      case 'completed':
        return const Color(0xFFDCFCE7); // green-100
      case 'cancelled':
        return const Color(0xFFF3F4F6); // gray-100
      default:
        return const Color(0xFFF3F4F6); // gray-100
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF854D0E); // yellow-800
      case 'confirmed':
        return const Color(0xFF1E40AF); // blue-800
      case 'completed':
        return const Color(0xFF166534); // green-800
      case 'cancelled':
        return const Color(0xFF1F2937); // gray-800
      default:
        return const Color(0xFF1F2937); // gray-800
    }
  }

  void _showActivityDetails(BuildContext context, dynamic activity) {
    String title = '';
    String? description;
    String? location;
    String dateStr = '';
    String status = '';
    String? rateInfo;

    if (activity is Job) {
      title = activity.clientName;
      description = activity.notes;
      location = activity.location;
      dateStr = activity.date;
      status = 'PENDING';
      rateInfo = '${activity.currency ?? 'USD'} ${activity.rate.toStringAsFixed(2)}';
    } else if (activity is Event) {
      title = activity.clientName ?? 'Event Details';
      description = activity.notes;
      location = activity.location;
      dateStr = activity.date?.toIso8601String() ?? '';
      status = activity.status?.toString().split('.').last.toUpperCase() ?? 'SCHEDULED';
      if (activity.dayRate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.dayRate!.toStringAsFixed(2)}';
      }
    } else if (activity is Casting) {
      title = activity.title;
      description = activity.description;
      location = activity.location;
      dateStr = activity.date.toIso8601String();
      status = activity.status.toUpperCase();
      if (activity.rate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}';
      }
    } else if (activity is Test) {
      title = activity.title;
      description = activity.description;
      location = activity.location;
      dateStr = activity.date.toIso8601String();
      status = activity.status.toUpperCase();
      if (activity.rate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}';
      }
    } else {
      title = 'Unknown Activity';
      description = 'No description available';
      location = 'Unknown location';
      dateStr = '';
      status = 'UNKNOWN';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null && description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Location:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              location ?? 'No location specified',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Date:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              () {
                try {
                  final date = DateTime.parse(dateStr);
                  return DateFormat('EEEE, MMMM d, y').format(date);
                } catch (e) {
                  return dateStr.isNotEmpty ? dateStr : 'No date specified';
                }
              }(),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(color: Colors.white),
            ),
            if (rateInfo != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Rate:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                rateInfo,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to edit page based on activity type
              if (activity is Job) {
                Navigator.pushNamed(context, '/new-job', arguments: activity);
              } else if (activity is Casting) {
                Navigator.pushNamed(context, '/new-casting', arguments: activity);
              } else if (activity is Test) {
                Navigator.pushNamed(context, '/new-test', arguments: activity);
              } else if (activity is Event) {
                // Route to the correct event type page
                String route;
                switch (activity.type) {
                  case EventType.option:
                    route = '/new-option';
                    break;
                  case EventType.job:
                    route = '/new-job';
                    break;
                  case EventType.directOption:
                    route = '/new-direct-option';
                    break;
                  case EventType.directBooking:
                    route = '/new-direct-booking';
                    break;
                  case EventType.casting:
                    route = '/new-casting';
                    break;
                  case EventType.onStay:
                    route = '/new-on-stay';
                    break;
                  case EventType.test:
                    route = '/new-test';
                    break;
                  case EventType.polaroids:
                    route = '/new-polaroid';
                    break;
                  case EventType.meeting:
                    route = '/new-meeting';
                    break;
                  case EventType.other:
                    route = '/new-event';
                    break;
                }
                Navigator.pushNamed(context, route, arguments: {
                  'eventType': activity.type,
                  'event': activity,
                });
              }
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    final typeColor = _getTypeColor(activity);
    final typeName = _getTypeName(activity);

    String activityStatus = '';
    String title = '';
    String? location;
    String? description;
    String? rateInfo;
    String dateDisplay = '';

    if (activity is Job) {
      activityStatus = 'pending';
      title = activity.clientName;
      location = activity.location;
      description = activity.notes;
      rateInfo = '${activity.currency ?? 'USD'} ${activity.rate.toStringAsFixed(2)}';
      try {
        final date = DateTime.parse(activity.date);
        dateDisplay = DateFormat('MMM d, y').format(date);
      } catch (e) {
        dateDisplay = activity.date;
      }
    } else if (activity is Event) {
      activityStatus = activity.status?.toString().split('.').last ?? 'scheduled';
      title = activity.clientName ?? 'Untitled Event';
      location = activity.location;
      description = activity.notes;
      if (activity.dayRate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.dayRate!.toStringAsFixed(2)}';
      }
      try {
        if (activity.date != null) {
          dateDisplay = DateFormat('MMM d, y').format(activity.date!);
        } else {
          dateDisplay = 'No date';
        }
      } catch (e) {
        dateDisplay = 'Invalid date';
      }
    } else if (activity is Casting) {
      activityStatus = activity.status;
      title = activity.title;
      location = activity.location;
      description = activity.description;
      if (activity.rate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}';
      }
      try {
        dateDisplay = DateFormat('MMM d, y').format(activity.date);
      } catch (e) {
        dateDisplay = 'Invalid date';
      }
    } else if (activity is Test) {
      activityStatus = activity.status;
      title = activity.title;
      location = activity.location;
      description = activity.description;
      if (activity.rate != null) {
        rateInfo = '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}';
      }
      try {
        dateDisplay = DateFormat('MMM d, y').format(activity.date);
      } catch (e) {
        dateDisplay = 'Invalid date';
      }
    } else {
      activityStatus = 'unknown';
      title = 'Untitled';
      location = 'Unknown location';
      description = 'No description';
      dateDisplay = 'No date';
    }

    final statusColor = _getStatusColor(activityStatus);
    final statusTextColor = _getStatusTextColor(activityStatus);

    return ui.Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showActivityDetails(context, activity);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      typeName,
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ui.Badge(
                    label: activityStatus,
                    backgroundColor: statusColor,
                    textColor: statusTextColor,
                  ),
                  const Spacer(),
                  Text(
                    dateDisplay,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (location != null && location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (rateInfo != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      rateInfo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _filteredActivities;

    return AppLayout(
      currentPage: '/activities',
      title: 'All Activities',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;
          final isMediumScreen = constraints.maxWidth < 1200;

          return Column(
            children: [
              // Header with title and add button
              _buildHeader(isSmallScreen),
              const SizedBox(height: 24),

              // Filters section
              _buildFilters(isSmallScreen, isMediumScreen),
              const SizedBox(height: 16),

              // Results count and clear filters
              _buildResultsHeader(filteredActivities.length, isSmallScreen),
              const SizedBox(height: 16),

              // Activities List or Table
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : filteredActivities.isEmpty
                            ? _buildEmptyState()
                            : isSmallScreen
                                ? _buildMobileList(filteredActivities)
                                : _buildDesktopTable(filteredActivities),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Activities',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage all your modeling activities in one place',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/add-event');
            // Refresh the list if an activity was created
            if (result == true) {
              _loadActivities();
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(isSmallScreen ? 'Add' : 'Add Activity'),
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
    );
  }

  Widget _buildFilters(bool isSmallScreen, bool isMediumScreen) {
    return ui.Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: [
            // Search
            TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.goldColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.goldColor),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
              style: const TextStyle(color: Colors.white),
              // Add cursor styling for better visibility
              cursorColor: AppTheme.goldColor,
              cursorWidth: 2.0,
              showCursor: true,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Filter Row - Responsive layout
            if (isSmallScreen)
              Column(
                children: [
                  _buildFilterDropdown('Activity Type', _typeFilter, _types,
                      (value) => setState(() => _typeFilter = value!)),
                  const SizedBox(height: 12),
                  _buildFilterDropdown('Status', _statusFilter, _statuses,
                      (value) => setState(() => _statusFilter = value!)),
                  const SizedBox(height: 12),
                  _buildFilterDropdown('Sort By', _sortBy, _sortOptions,
                      (value) => setState(() => _sortBy = value!)),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                      child: _buildFilterDropdown(
                          'Activity Type',
                          _typeFilter,
                          _types,
                          (value) => setState(() => _typeFilter = value!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildFilterDropdown(
                          'Status',
                          _statusFilter,
                          _statuses,
                          (value) => setState(() => _statusFilter = value!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildFilterDropdown(
                          'Sort By',
                          _sortBy,
                          _sortOptions,
                          (value) => setState(() => _sortBy = value!))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.goldColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.goldColor),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      dropdownColor: const Color(0xFF2A2A2A),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item == 'all' ? 'All ${label}s' : item.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultsHeader(int count, bool isSmallScreen) {
    return Row(
      children: [
        Text(
          '$count activities found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _searchTerm = '';
              _typeFilter = 'all';
              _statusFilter = 'all';
              _sortBy = 'date';
            });
          },
          icon: const Icon(Icons.clear, color: AppTheme.goldColor, size: 16),
          label: const Text(
            'Clear Filters',
            style: TextStyle(color: AppTheme.goldColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found matching your filters',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria or add a new activity',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<dynamic> activities) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildActivityCard(activities[index]),
    );
  }

  Widget _buildDesktopTable(List<dynamic> activities) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Client',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                SizedBox(
                    width: 100,
                    child: Text('Actions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Color(0xFF2E2E2E), height: 1),
              itemBuilder: (context, index) =>
                  _buildTableRow(activities[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic activity) {
    final typeColor = _getTypeColor(activity);
    final typeName = _getTypeName(activity);

    String activityStatus = '';
    if (activity is Job) {
      activityStatus = 'pending';
    } else if (activity is Event) {
      activityStatus = activity.status?.toString().split('.').last ?? 'scheduled';
    } else {
      activityStatus = activity.status ?? 'unknown';
    }

    final statusColor = _getStatusColor(activityStatus);

    return InkWell(
      onTap: () => _showActivityDetails(context, activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity is Job
                        ? activity.clientName
                        : activity is Event
                            ? activity.clientName ?? 'Unknown Client'
                            : activity is Casting
                                ? activity.title
                                : activity is Test
                                    ? activity.title
                                    : 'Unknown Client',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show notes/description based on activity type
                  if ((activity is Job && activity.notes != null && activity.notes!.isNotEmpty) ||
                      (activity is Event && activity.notes != null && activity.notes!.isNotEmpty) ||
                      (activity is Casting && activity.description != null && activity.description!.isNotEmpty) ||
                      (activity is Test && activity.description != null && activity.description!.isNotEmpty))
                    Text(
                      activity is Job
                          ? activity.notes!
                          : activity is Event
                              ? activity.notes!
                              : activity is Casting
                                  ? activity.description!
                                  : activity is Test
                                      ? activity.description!
                                      : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeName,
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(activity is Job
                        ? activity.date
                        : activity.date?.toString() ?? ''),
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (_getActivityTime(activity) != null)
                    Text(
                      _getActivityTime(activity)!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                activity.location ?? 'TBD',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activityStatus.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: AppTheme.goldColor, size: 18),
                    onPressed: () async {
                      // Navigate to edit page based on activity type
                      bool? result;
                      if (activity is Job) {
                        result = await Navigator.pushNamed(context, '/new-job',
                            arguments: activity) as bool?;
                      } else if (activity is Casting) {
                        result = await Navigator.pushNamed(context, '/new-casting',
                            arguments: activity) as bool?;
                      } else if (activity is Test) {
                        result = await Navigator.pushNamed(context, '/new-test',
                            arguments: activity) as bool?;
                      } else if (activity is Event) {
                        // Route to the correct event type page
                        String route;
                        switch (activity.type) {
                          case EventType.option:
                            route = '/new-option';
                            break;
                          case EventType.job:
                            route = '/new-job';
                            break;
                          case EventType.directOption:
                            route = '/new-direct-option';
                            break;
                          case EventType.directBooking:
                            route = '/new-direct-booking';
                            break;
                          case EventType.casting:
                            route = '/new-casting';
                            break;
                          case EventType.onStay:
                            route = '/new-on-stay';
                            break;
                          case EventType.test:
                            route = '/new-test';
                            break;
                          case EventType.polaroids:
                            route = '/new-polaroid';
                            break;
                          case EventType.meeting:
                            route = '/new-meeting';
                            break;
                          case EventType.other:
                            route = '/new-event';
                            break;
                        }
                        result = await Navigator.pushNamed(context, route,
                            arguments: {
                              'eventType': activity.type,
                              'event': activity,
                            }) as bool?;
                      }

                      // Refresh the list if edit was successful
                      if (result == true) {
                        _loadActivities();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red, size: 18),
                    onPressed: () => _showDeleteConfirmation(activity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showDeleteConfirmation(dynamic activity) {
    String activityName = '';
    if (activity is Job) {
      activityName = activity.clientName;
    } else if (activity is Event) {
      activityName = activity.clientName ?? 'Event';
    } else if (activity is Casting) {
      activityName = activity.clientName ?? 'Casting';
    } else if (activity is Test) {
      activityName = activity.clientName ?? 'Test';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Activity',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$activityName"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteActivity(activity);
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

  Future<void> _deleteActivity(dynamic activity) async {
    try {
      bool success = false;

      if (activity is Job && activity.id != null) {
        success = await JobsService.delete(activity.id!);
      } else if (activity is Event && activity.id != null) {
        final eventsService = EventsService();
        success = await eventsService.deleteEvent(activity.id!);
      } else if (activity is Casting) {
        success = await CastingsService.delete(activity.id);
      } else if (activity is Test) {
        success = await TestsService.delete(activity.id);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadActivities(); // Refresh the list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete activity'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getActivityTime(dynamic activity) {
    if (activity is Job && activity.time != null) {
      return activity.time;
    } else if (activity is Event && activity.startTime != null) {
      return activity.startTime;
    }
    return null;
  }
}
