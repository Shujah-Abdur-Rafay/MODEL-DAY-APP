import 'package:flutter/material.dart';
import 'package:new_flutter/models/casting.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NewCastingPage extends StatefulWidget {
  final Casting? casting;

  const NewCastingPage({super.key, this.casting});

  @override
  State<NewCastingPage> createState() => _NewCastingPageState();
}

class _NewCastingPageState extends State<NewCastingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  final _clientController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedAgentId;
  String _status = 'pending';
  DateTime _date = DateTime.now();
  bool _isEditing = false;

  final List<String> _jobTypes = [
    'Fashion Shoot',
    'Commercial',
    'Editorial',
    'Portrait',
    'Beauty',
    'Lifestyle',
    'Product',
    'Other',
  ];

  final List<String> _statuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
    'declined',
    'postponed',
  ];

  @override
  void initState() {
    super.initState();
    // Handle both widget.casting and route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Casting) {
        _populateForm(args);
      } else if (widget.casting != null) {
        _populateForm(widget.casting!);
      }
    });
  }

  void _populateForm(Casting casting) {
    _clientController.text = casting.title; // Map title to client
    _locationController.text = casting.location ?? '';

    // Parse description to extract individual fields
    _parseDescriptionFields(casting.description ?? '');

    setState(() {
      _status = casting.status;
      _date = casting.date;
      _isEditing = true;
    });
  }

  void _parseDescriptionFields(String description) {
    // Parse the description string to extract individual field values
    final lines = description.split('\n\n');

    for (final line in lines) {
      if (line.startsWith('Job Type: ')) {
        final jobType = line.substring('Job Type: '.length);
        if (_jobTypes.contains(jobType)) {
          _jobTypeController.text = jobType;
        }
      } else if (line.startsWith('Start Time: ')) {
        _startTimeController.text = line.substring('Start Time: '.length);
      } else if (line.startsWith('End Time: ')) {
        _endTimeController.text = line.substring('End Time: '.length);
      } else if (line.startsWith('Agent ID: ')) {
        _selectedAgentId = line.substring('Agent ID: '.length);
      } else if (line.startsWith('Notes: ')) {
        _notesController.text = line.substring('Notes: '.length);
      }
    }
  }

  TimeOfDay? _parseTimeString(String timeString) {
    if (timeString.isEmpty) return null;

    try {
      // Handle different time formats
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('Error parsing time string: $timeString');
    }
    return null;
  }

  @override
  void dispose() {
    _clientController.dispose();
    _jobTypeController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCasting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      final editingCasting = args is Casting ? args : widget.casting;

      final data = {
        'title': _clientController.text,
        'description': _buildDescriptionString(),
        'date': _date.toIso8601String(),
        'location': _locationController.text,
        'requirements': '',
        'status': _status,
        'rate': null,
        'currency': 'USD',
        'images': [],
      };

      if (editingCasting != null) {
        // Update existing casting
        await Casting.update(editingCasting.id, data);
      } else {
        // Create new casting
        await Casting.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingCasting != null
                ? 'Casting updated successfully'
                : 'Casting created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save casting: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isEditing = args is Casting || widget.casting != null;

    return AppLayout(
      currentPage: '/new-casting',
      title: isEditing ? 'Edit Casting' : 'New Casting',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client
              ui.Input(
                label: 'Client *',
                controller: _clientController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Job Type *',
                  border: OutlineInputBorder(),
                ),
                value: _jobTypeController.text.isNotEmpty && _jobTypes.contains(_jobTypeController.text)
                    ? _jobTypeController.text
                    : null,
                items: _jobTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _jobTypeController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a job type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMM d, yyyy').format(_date),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _date = date;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start and End Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Start Time *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      controller: _startTimeController,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _parseTimeString(_startTimeController.text) ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.goldColor,
                                  surface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() {
                            _startTimeController.text = time.format(context);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select start time';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'End Time *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      controller: _endTimeController,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _parseTimeString(_endTimeController.text) ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.goldColor,
                                  surface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() {
                            _endTimeController.text = time.format(context);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select end time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              ui.Input(
                label: 'Location *',
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Agent
              AgentDropdown(
                selectedAgentId: _selectedAgentId,
                labelText: 'Agent *',
                hintText: 'Select an agent',
                onChanged: (value) {
                  setState(() {
                    _selectedAgentId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select an agent';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _statuses.contains(_status) ? _status : null,
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Transfer to Option/Job (only in edit view)
              if (_isEditing) ...[
                ui.Input(
                  label: 'Transfer to Option/Job',
                  controller: TextEditingController(),
                  readOnly: true,
                  onTap: () {
                    // Transfer functionality will allow converting castings to options/jobs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer functionality coming soon')),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              ui.Input(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: Button(
                  text: isEditing ? 'Update Casting' : 'Create Casting',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _saveCasting,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDescriptionString() {
    List<String> parts = [];

    if (_jobTypeController.text.trim().isNotEmpty) {
      parts.add('Job Type: ${_jobTypeController.text.trim()}');
    }

    if (_startTimeController.text.trim().isNotEmpty) {
      parts.add('Start Time: ${_startTimeController.text.trim()}');
    }

    if (_endTimeController.text.trim().isNotEmpty) {
      parts.add('End Time: ${_endTimeController.text.trim()}');
    }

    if (_selectedAgentId != null) {
      parts.add('Agent ID: $_selectedAgentId');
    }

    if (_notesController.text.trim().isNotEmpty) {
      parts.add('Notes: ${_notesController.text.trim()}');
    }

    return parts.join('\n\n');
  }
}
