import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/services/events_service.dart';
import 'package:new_flutter/services/agents_service.dart';

import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _usageRateController = TextEditingController();
  final _notesController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _photographerController = TextEditingController();
  final _subjectController = TextEditingController();
  final _eventNameController = TextEditingController();

  String _selectedEventType = '';
  bool _isLoading = false;
  bool _showForm = false;

  // Form state
  DateTime _selectedDate = DateTime.now();
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final String _selectedCurrency = 'USD';
  final EventStatus _selectedStatus = EventStatus.scheduled;
  final PaymentStatus _selectedPaymentStatus = PaymentStatus.unpaid;
  String? _selectedAgentId;
  final String _selectedTestType = 'free';
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _locationController.dispose();
    _dayRateController.dispose();
    _usageRateController.dispose();
    _notesController.dispose();
    _jobTypeController.dispose();
    _photographerController.dispose();
    _subjectController.dispose();
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    try {
      final agentsService = AgentsService();
      await agentsService.getAgents();
      // Agents are loaded but not stored since they're not used in this page
    } catch (e) {
      debugPrint('Error loading agents: $e');
    }
  }

  final List<Map<String, dynamic>> _eventTypes = [
    {
      'value': 'directbookings',
      'label': 'Direct Bookings',
      'color': Colors.teal
    },
    {'value': 'directoptions', 'label': 'Direct Options', 'color': Colors.cyan},
    {'value': 'jobs', 'label': 'Jobs', 'color': Colors.blue},
    {'value': 'castings', 'label': 'Castings', 'color': Colors.purple},
    {'value': 'test', 'label': 'Test', 'color': Colors.green},
    {'value': 'onstay', 'label': 'OnStay', 'color': Colors.orange},
    {'value': 'polaroids', 'label': 'Polaroids', 'color': Colors.pink},
    {'value': 'meetings', 'label': 'Meetings', 'color': Colors.indigo},
    {'value': 'aijobs', 'label': 'AI Jobs', 'color': Colors.white},
  ];







  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the event using EventsService
      final eventType = _getEventTypeFromString(_selectedEventType);
      if (eventType == null) {
        throw Exception('Invalid event type selected');
      }

      final eventData = {
        'type': eventType.toString().split('.').last,
        'client_name': _clientNameController.text.trim().isNotEmpty
            ? _clientNameController.text.trim()
            : null,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'start_time': _formatTimeOfDay(_startTime),
        'end_time': _formatTimeOfDay(_endTime),
        'location': _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        'agent_id': _selectedAgentId,
        'day_rate': double.tryParse(_dayRateController.text),
        'usage_rate': double.tryParse(_usageRateController.text),
        'currency': _selectedCurrency,
        'status': _selectedStatus.toString().split('.').last,
        'payment_status': _selectedPaymentStatus.toString().split('.').last,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        ..._buildAdditionalData(),
      };

      final eventsService = EventsService();
      await eventsService.createEvent(eventData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  EventType? _getEventTypeFromString(String typeString) {
    switch (typeString) {
      case 'options':
        return EventType.option;
      case 'jobs':
        return EventType.job;
      case 'directoptions':
        return EventType.directOption;
      case 'directbookings':
        return EventType.directBooking;
      case 'castings':
        return EventType.casting;
      case 'onstay':
        return EventType.onStay;
      case 'test':
        return EventType.test;
      case 'polaroids':
        return EventType.polaroids;
      case 'meetings':
        return EventType.meeting;
      case 'other':
        return EventType.other;
      default:
        return null;
    }
  }

  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _buildAdditionalData() {
    final data = <String, dynamic>{};

    switch (_selectedEventType) {
      case 'jobs':
      case 'directbookings':
        if (_jobTypeController.text.isNotEmpty) {
          data['job_type'] = _jobTypeController.text;
        }
        break;
      case 'directoptions':
        if (_jobTypeController.text.isNotEmpty) {
          data['option_type'] = _jobTypeController.text;
        }
        break;
      case 'castings':
        if (_jobTypeController.text.isNotEmpty) {
          data['casting_type'] = _jobTypeController.text;
        }
        break;
      case 'onstay':
        if (_jobTypeController.text.isNotEmpty) {
          data['onstay_details'] = _jobTypeController.text;
        }
        break;
      case 'aijobs':
        if (_jobTypeController.text.isNotEmpty) {
          data['ai_job_type'] = _jobTypeController.text;
        }
        break;
      case 'test':
      case 'polaroids':
        if (_photographerController.text.isNotEmpty) {
          data['photographer_name'] = _photographerController.text;
        }
        data['test_type'] = _selectedTestType;
        data['is_paid'] = _isPaid;
        break;
      case 'meetings':
        if (_subjectController.text.isNotEmpty) {
          data['subject'] = _subjectController.text;
        }
        break;
      case 'other':
        if (_eventNameController.text.isNotEmpty) {
          data['event_name'] = _eventNameController.text;
        }
        break;
    }

    return data;
  }



  Widget _buildExpandedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF2E2E2E)),
        const SizedBox(height: 32),
        const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Event-specific fields
        ..._buildEventSpecificFields(),

        // Date fields
        ..._buildDateFields(),

        // Time fields
        if (_needsTimeFields()) ...[
          const SizedBox(height: 24),
          ..._buildTimeFields(),
        ],

        // Location field
        if (_needsLocation()) ...[
          const SizedBox(height: 24),
          ui.Input(
            controller: _locationController,
            placeholder: 'Location',
          ),
        ],

        // Rate fields
        if (_needsRateFields()) ...[
          const SizedBox(height: 24),
          ..._buildRateFields(),
        ],

        // Notes
        const SizedBox(height: 24),
        ui.Input(
          controller: _notesController,
          placeholder: 'Notes (optional)',
          maxLines: 3,
        ),
      ],
    );
  }

  bool _needsTimeFields() {
    return _selectedEventType != 'onstay';
  }

  bool _needsLocation() {
    return true; // Most events need location
  }

  bool _needsRateFields() {
    return _selectedEventType == 'jobs' ||
           _selectedEventType == 'directbookings' ||
           _selectedEventType == 'directoptions' ||
           _selectedEventType == 'aijobs';
  }

  List<Widget> _buildEventSpecificFields() {
    switch (_selectedEventType) {
      case 'jobs':
      case 'directbookings':
        return [
          ui.Input(
            controller: _jobTypeController,
            placeholder: 'Job Type (e.g., Fashion Shoot, Commercial)',
          ),
          const SizedBox(height: 20),
        ];
      case 'directoptions':
        return [
          ui.Input(
            controller: _jobTypeController,
            placeholder: 'Option Type (e.g., Fashion Shoot, Commercial)',
          ),
          const SizedBox(height: 20),
        ];
      case 'castings':
        return [
          ui.Input(
            controller: _jobTypeController,
            placeholder: 'Casting Type (e.g., Commercial, Fashion)',
          ),
          const SizedBox(height: 20),
        ];
      case 'test':
      case 'polaroids':
        return [
          ui.Input(
            controller: _photographerController,
            placeholder: 'Photographer Name',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value ?? false;
                  });
                },
              ),
              const Text(
                'Paid Test/Polaroids',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ];
      case 'onstay':
        return [
          ui.Input(
            controller: _jobTypeController,
            placeholder: 'OnStay Details',
          ),
          const SizedBox(height: 16),
        ];
      case 'meetings':
        return [
          ui.Input(
            controller: _subjectController,
            placeholder: 'Meeting Subject',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Subject is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ];
      case 'aijobs':
        return [
          ui.Input(
            controller: _jobTypeController,
            placeholder: 'AI Job Type (e.g., Virtual Shoot, Digital Campaign)',
          ),
          const SizedBox(height: 16),
        ];
      case 'other':
        return [
          ui.Input(
            controller: _eventNameController,
            placeholder: 'Event Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Event name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ];
      default:
        return [];
    }
  }

  List<Widget> _buildDateFields() {
    return [
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildTimeFields() {
    return [
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context, true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _startTime != null
                          ? _startTime!.format(context)
                          : 'Start Time',
                      style: TextStyle(
                        color: _startTime != null ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context, false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _endTime != null
                          ? _endTime!.format(context)
                          : 'End Time',
                      style: TextStyle(
                        color: _endTime != null ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildRateFields() {
    return [
      Row(
        children: [
          Expanded(
            child: ui.Input(
              controller: _dayRateController,
              placeholder: 'Day Rate',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ui.Input(
              controller: _usageRateController,
              placeholder: 'Usage Rate',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/add-event',
      title: 'Add New Event',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Quick Add Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an event type and provide a client name to get started.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Client Name
              ui.Input(
                label: 'Client Name',
                controller: _clientNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Event Type Selection
              const Text(
                'Event Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedEventType.isEmpty || !_eventTypes.any((type) => type['value'] == _selectedEventType) ? null : _selectedEventType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select event type',
                    style: TextStyle(color: Colors.white70),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an event type';
                    }
                    return null;
                  },
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: type['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type['label'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value ?? '';
                      _showForm = value != null && value.isNotEmpty;
                    });
                  },
                ),
              ),

              // Show expanded form when event type is selected
              if (_showForm && _selectedEventType.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildExpandedForm(),
              ],

              // Submit Buttons
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Button(
                      onPressed: _isLoading ? null : _handleSubmit,
                      text: _isLoading ? 'Creating...' : (_showForm ? 'Create Event' : 'Continue'),
                      variant: ButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
