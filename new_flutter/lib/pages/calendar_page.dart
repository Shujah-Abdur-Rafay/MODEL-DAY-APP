import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/casting.dart';
import '../models/test.dart';
import '../models/event.dart';
import '../services/jobs_service.dart';
import '../services/events_service.dart';
import '../theme/app_theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _viewMode = 'month';
  bool _isLoading = true;
  String? _error;
  Map<DateTime, List<dynamic>> _events = {};

  // Performance optimization flags
  bool _isDisposed = false;
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadEvents() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingEvents || _isDisposed) return;

    try {
      _isLoadingEvents = true;

      if (!_isDisposed) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Load events with timeout for older devices
      final futures = await Future.wait([
        JobsService.list().timeout(const Duration(seconds: 10)),
        Casting.list().timeout(const Duration(seconds: 10)),
        Test.list().timeout(const Duration(seconds: 10)),
        EventsService().getEvents().timeout(const Duration(seconds: 10)),
      ]).timeout(const Duration(seconds: 30));

      if (_isDisposed) return;

      final jobs = futures[0] as List<Job>;
      final castings = futures[1] as List<Casting>;
      final tests = futures[2] as List<Test>;
      final generalEvents = futures[3] as List<Event>;

      // Use more memory-efficient map building
      final events = <DateTime, List<dynamic>>{};

      // Group jobs by date with better error handling
      for (final job in jobs) {
        if (_isDisposed) return;
        try {
          final date = DateTime.parse(job.date);
          final dateKey = DateTime(date.year, date.month, date.day);
          if (events[dateKey] == null) {
            events[dateKey] = [job];
          } else {
            events[dateKey]!.add(job);
          }
        } catch (e) {
          debugPrint('Error parsing job date: ${job.date} - $e');
          continue;
        }
      }

      // Group castings by date with disposal check
      for (final casting in castings) {
        if (_isDisposed) return;
        try {
          final date = DateTime(
            casting.date.year,
            casting.date.month,
            casting.date.day,
          );
          if (events[date] == null) {
            events[date] = [casting];
          } else {
            events[date]!.add(casting);
          }
        } catch (e) {
          debugPrint('Error processing casting date: $e');
          continue;
        }
      }

      // Group tests by date with disposal check
      for (final test in tests) {
        if (_isDisposed) return;
        try {
          final date = DateTime(test.date.year, test.date.month, test.date.day);
          if (events[date] == null) {
            events[date] = [test];
          } else {
            events[date]!.add(test);
          }
        } catch (e) {
          debugPrint('Error processing test date: $e');
          continue;
        }
      }

      // Group general events by date with disposal check
      for (final event in generalEvents) {
        if (_isDisposed) return;
        try {
          if (event.date != null) {
            final date = DateTime(
              event.date!.year,
              event.date!.month,
              event.date!.day,
            );
            if (events[date] == null) {
              events[date] = [event];
            } else {
              events[date]!.add(event);
            }
          }
        } catch (e) {
          debugPrint('Error processing general event date: $e');
          continue;
        }
      }

      if (!_isDisposed) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
        debugPrint('📅 Loaded ${events.length} event dates with total events: ${events.values.fold(0, (sum, list) => sum + list.length)}');
      }
    } catch (e) {
      debugPrint('❌ Error loading events: $e');
      if (!_isDisposed) {
        setState(() {
          _error = 'Failed to load events. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      _isLoadingEvents = false;
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  void _showDayEventsDialog(DateTime selectedDate, List<dynamic> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Events for ${DateFormat('MMM d, yyyy').format(selectedDate)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getEventColor(event),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          _getEventTitle(event),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getEventType(event),
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            if (_getEventTime(event) != 'All day')
                              Text(
                                _getEventTime(event),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showEventDetails(context, event);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddEventDialog(selectedDate);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldColor,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Event',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Event Type',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                hint: const Text(
                  'Select event type',
                  style: TextStyle(color: Colors.grey),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'option', child: Text('Option')),
                  DropdownMenuItem(value: 'job', child: Text('Job')),
                  DropdownMenuItem(value: 'directOption', child: Text('Direct Option')),
                  DropdownMenuItem(value: 'directBooking', child: Text('Direct Booking')),
                  DropdownMenuItem(value: 'casting', child: Text('Casting')),
                  DropdownMenuItem(value: 'onStay', child: Text('On Stay')),
                  DropdownMenuItem(value: 'test', child: Text('Test')),
                  DropdownMenuItem(value: 'polaroids', child: Text('Polaroids')),
                  DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context);
                    _navigateToEventCreation(value, selectedDate);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Will be scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToEventCreation(String eventType, DateTime selectedDate) {
    switch (eventType) {
      case 'option':
        Navigator.pushNamed(
          context,
          '/new-option',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'job':
        Navigator.pushNamed(
          context,
          '/new-job',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'directOption':
        Navigator.pushNamed(
          context,
          '/new-direct-option',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'directBooking':
        Navigator.pushNamed(
          context,
          '/new-direct-booking',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'casting':
        Navigator.pushNamed(
          context,
          '/new-casting',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'onStay':
        Navigator.pushNamed(
          context,
          '/new-on-stay',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'test':
        Navigator.pushNamed(
          context,
          '/new-test',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'polaroids':
        Navigator.pushNamed(
          context,
          '/new-polaroids',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      case 'meeting':
        Navigator.pushNamed(
          context,
          '/new-meeting',
          arguments: {'preselectedDate': selectedDate},
        ).then((_) => _loadEvents());
        break;
      default:
        Navigator.pushNamed(
          context,
          '/new-event',
          arguments: {'preselectedDate': selectedDate, 'eventType': eventType},
        ).then((_) => _loadEvents());
        break;
    }
  }

  Color _getEventColor(dynamic event) {
    if (event is Job) return Colors.blue;
    if (event is Casting) return Colors.purple;
    if (event is Test) return Colors.orange;
    if (event is Event) {
      switch (event.type) {
        case EventType.job:
          return Colors.blue;
        case EventType.casting:
          return Colors.purple;
        case EventType.test:
          return Colors.orange;
        case EventType.option:
          return Colors.green;
        case EventType.directBooking:
          return Colors.red;
        case EventType.directOption:
          return Colors.teal;
        case EventType.onStay:
          return Colors.indigo;
        case EventType.polaroids:
          return Colors.pink;
        case EventType.meeting:
          return Colors.amber;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  String _getEventType(dynamic event) {
    if (event is Job) return 'Job';
    if (event is Casting) return 'Casting';
    if (event is Test) return 'Test';
    if (event is Event) {
      switch (event.type) {
        case EventType.job:
          return 'Job';
        case EventType.casting:
          return 'Casting';
        case EventType.test:
          return 'Test';
        case EventType.option:
          return 'Option';
        case EventType.directBooking:
          return 'Direct Booking';
        case EventType.directOption:
          return 'Direct Option';
        case EventType.onStay:
          return 'On Stay';
        case EventType.polaroids:
          return 'Polaroids';
        case EventType.meeting:
          return 'Meeting';
        default:
          return 'Event';
      }
    }
    return 'Event';
  }

  String _getEventTime(dynamic event) {
    if (event is Job && event.time != null) {
      return event.time!;
    } else if (event is Event && event.startTime != null) {
      return event.startTime!;
    }
    return 'All day';
  }

  String _getEventTitle(dynamic event) {
    if (event is Job) {
      return event.clientName;
    } else if (event is Casting) {
      return event.clientName ?? 'Casting';
    } else if (event is Test) {
      return event.clientName ?? 'Test';
    } else if (event is Event) {
      return event.clientName ?? _getEventType(event);
    }
    return 'Untitled';
  }

  String _getTruncatedEventTitle(dynamic event) {
    String title = _getEventTitle(event);
    // Truncate long titles to fit in calendar cells - be very aggressive
    if (title.length > 4) {
      return title.substring(0, 4);
    }
    return title;
  }

  String _getEventLocation(dynamic event) {
    if (event is Job) {
      return event.location.isEmpty ? 'No location' : event.location;
    } else if (event is Casting) {
      return event.location ?? 'No location';
    } else if (event is Test) {
      return event.location ?? 'No location';
    } else if (event is Event) {
      return event.location ?? 'No location';
    }
    return 'No location';
  }

  String? _getEventDescription(dynamic event) {
    if (event is Job) {
      return event.notes;
    } else if (event is Event) {
      return event.notes;
    }
    return null;
  }

  Widget _buildCalendarDay(DateTime day, bool isToday, bool isSelected, {bool isOutside = false}) {
    // Early return for disposed state
    if (_isDisposed) return const SizedBox.shrink();

    final events = _getEventsForDay(day);
    final hasEvents = events.isNotEmpty;

    // Pre-calculate colors to avoid repeated calculations
    Color? backgroundColor;
    Color textColor = Colors.white;
    Color eventTextColor = Colors.white;

    if (isSelected) {
      backgroundColor = AppTheme.goldColor;
      textColor = Colors.black;
      eventTextColor = Colors.black;
    } else if (isToday) {
      backgroundColor = AppTheme.goldColor.withValues(alpha: 0.7);
      textColor = Colors.black;
      eventTextColor = Colors.black;
    } else if (isOutside) {
      textColor = Colors.white.withValues(alpha: 0.4);
      eventTextColor = Colors.white.withValues(alpha: 0.4);
    }

    // Cache screen width to avoid repeated MediaQuery calls
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth < 600;
    final isMobile = screenWidth < 768;

    // Pre-calculate all sizes to improve performance
    final cellWidth = isVerySmall ? 40.0 : isSmall ? 45.0 : isMobile ? 50.0 : 55.0;
    final cellHeight = isVerySmall ? 65.0 : isSmall ? 70.0 : isMobile ? 75.0 : 80.0;
    final dayFontSize = isVerySmall ? 12.0 : isSmall ? 14.0 : 16.0;
    final eventFontSize = isVerySmall ? 7.0 : isSmall ? 8.0 : isMobile ? 9.0 : 10.0;

    return Container(
          margin: EdgeInsets.all(isVerySmall ? 1 : 2),
          padding: EdgeInsets.symmetric(
            vertical: isVerySmall ? 2 : 3,
            horizontal: isVerySmall ? 1 : 2
          ),
          width: cellWidth,
          height: cellHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(isVerySmall ? 6 : 8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Day number
              Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: dayFontSize,
                ),
              ),

              // Event names
              if (hasEvents) ...[
                SizedBox(height: isVerySmall ? 1 : 2),
                Expanded(
                  child: ClipRect(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isVerySmall ? 1 : 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (events.length == 1) ...[
                            // Show single event name (truncated)
                            Flexible(
                              child: Text(
                                _getTruncatedEventTitle(events.first),
                                style: TextStyle(
                                  color: eventTextColor,
                                  fontSize: eventFontSize,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else ...[
                            // Show event count for multiple events
                            Flexible(
                              child: Text(
                                '${events.length}',
                                style: TextStyle(
                                  color: eventTextColor,
                                  fontSize: eventFontSize,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
  }

  void _showEventDetails(BuildContext context, dynamic event) {
    // Get event title
    String title = 'Event Details';
    if (event is Job) {
      title = event.clientName;
    } else if (event is Casting) {
      title = event.clientName ?? 'Casting';
    } else if (event is Test) {
      title = event.clientName ?? 'Test';
    } else if (event is Event) {
      title = event.clientName ?? 'Event';
    }

    // Get event date
    DateTime? eventDate;
    if (event is Job) {
      eventDate = DateTime.tryParse(event.date);
    } else if (event is Casting) {
      eventDate = event.date;
    } else if (event is Test) {
      eventDate = event.date;
    } else if (event is Event) {
      eventDate = event.date;
    }

    // Get event location
    String? location;
    if (event is Job) {
      location = event.location;
    } else if (event is Casting) {
      location = event.location;
    } else if (event is Test) {
      location = event.location;
    } else if (event is Event) {
      location = event.location;
    }

    // Get event time
    String? time;
    if (event is Job && event.time != null) {
      time = event.time;
    } else if (event is Event && event.startTime != null) {
      time = event.startTime;
    }

    // Get event rate
    double? rate;
    String? currency;
    if (event is Job) {
      rate = event.rate;
      currency = event.currency;
    } else if (event is Event) {
      rate = event.dayRate;
      currency = event.currency;
    }

    // Get event notes/description
    String? notes;
    if (event is Job) {
      notes = event.notes;
    } else if (event is Event) {
      notes = event.notes;
    }
    // Note: Casting and Test models don't have notes field

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
            if (notes != null) ...[
              const Text(
                'Notes:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                notes,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Location:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              location ?? 'No location specified',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Date:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              eventDate != null
                ? DateFormat('EEEE, MMMM d, y').format(eventDate)
                : 'Date not specified',
              style: const TextStyle(color: Colors.white),
            ),
            if (time != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Time:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (rate != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Rate:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${currency ?? 'USD'} ${rate.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final color = _getEventColor(event);
    final type = _getEventType(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showEventDetails(context, event);
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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getEventTime(event),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getEventTitle(event),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEventLocation(event),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              if (_getEventDescription(event) != null) ...[
                const SizedBox(height: 8),
                Text(
                  _getEventDescription(event)!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(0),
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 0, // Disable default markers since we use custom builders
                    todayDecoration: const BoxDecoration(
                      color: Colors.transparent, // Handled by custom builder
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.transparent, // Handled by custom builder
                    ),
                    defaultDecoration: const BoxDecoration(
                      color: Colors.transparent, // Handled by custom builder
                    ),
                    outsideDaysVisible: false,
                    canMarkersOverflow: false,
                    cellMargin: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 1 : MediaQuery.of(context).size.width < 600 ? 2 : 3),
                    cellPadding: const EdgeInsets.all(0),
                    weekendTextStyle: const TextStyle(color: Colors.white),
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    todayTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white70),
                    weekendStyle: TextStyle(color: Colors.white70),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, false, false);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, true, false);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, false, true);
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, false, false, isOutside: true);
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Show events for the selected day
                    final events = _getEventsForDay(selectedDay);
                    if (events.isNotEmpty) {
                      _showDayEventsDialog(selectedDay, events);
                    } else {
                      _showAddEventDialog(selectedDay);
                    }
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              SizedBox(
                height:
                    constraints.maxHeight * 0.5, // Use half of available height
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    if (_selectedDay != null) ...[
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getEventsForDay(
                        _selectedDay!,
                      ).map((event) => _buildEventCard(event)),
                      if (_getEventsForDay(_selectedDay!).isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 32),
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No events for this day',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgendaView() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('This Week', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 7; i++) ...[
          _buildDayEvents(startOfWeek.add(Duration(days: i))),
          if (i < 6) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDayEvents(DateTime day) {
    final events = _getEventsForDay(day);
    final isToday = isSameDay(day, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? AppTheme.goldColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                DateFormat('E, MMM d').format(day),
                style: TextStyle(
                  color: isToday ? Colors.black : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (events.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...events.map((event) => _buildEventCard(event)),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No events',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/calendar',
      title: 'Calendar',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/new-option');
          },
          tooltip: 'Add Option',
        ),
        IconButton(
          icon: Icon(
            _viewMode == 'month' ? Icons.view_agenda : Icons.calendar_month,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _viewMode = _viewMode == 'month' ? 'agenda' : 'month';
            });
          },
          tooltip: 'Toggle View',
        ),
      ],
      child: _buildSafeContent(),
    );
  }

  Widget _buildSafeContent() {
    try {
      // Early return for disposed state to prevent white screens
      if (_isDisposed) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      if (_isLoading) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading calendar events...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }

      if (_error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEvents,
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }

      return _viewMode == 'month' ? _buildCalendarView() : _buildAgendaView();
    } catch (e) {
      debugPrint('❌ Error in calendar build: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Something went wrong with the calendar.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!_isDisposed) {
                  setState(() {
                    _error = null;
                    _isLoading = false;
                  });
                  _loadEvents();
                }
              },
              child: Text('Restart Calendar'),
            ),
          ],
        ),
      );
    }
  }
}
