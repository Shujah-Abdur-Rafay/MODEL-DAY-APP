import 'package:flutter/material.dart';
import 'package:new_flutter/models/test.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:intl/intl.dart';

class NewTestPage extends StatefulWidget {
  const NewTestPage({super.key});

  @override
  State<NewTestPage> createState() => _NewTestPageState();
}

class _NewTestPageState extends State<NewTestPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  Test? _existingTest;
  bool get _isEditing => _existingTest != null;

  final _photographerNameController = TextEditingController();
  final _rateController = TextEditingController();
  final _callTimeController = TextEditingController();
  TimeOfDay _callTime = TimeOfDay.now();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedAgentId;
  String _testType = 'free';
  String _status = 'pending';
  DateTime _date = DateTime.now();

  final List<String> _testTypes = ['free', 'paid'];
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize call time controller with current time
      _callTimeController.text = _callTime.format(context);

      final args = ModalRoute.of(context)?.settings.arguments;
      debugPrint('🧪 NewTestPage initState - Arguments type: ${args.runtimeType}');
      if (args is Test) {
        debugPrint('🧪 NewTestPage initState - Initializing with existing test: ${args.title}');
        _initializeWithExistingTest(args);
      } else {
        debugPrint('🧪 NewTestPage initState - No test data to populate');
        // Set initial call time for new tests
        setState(() {
          _callTimeController.text = _callTime.format(context);
        });
      }
    });
  }

  void _initializeWithExistingTest(Test test) {
    debugPrint('🧪 Initializing form with test: ${test.title} (${test.id})');
    debugPrint('🧪 Test data: title=${test.title}, location=${test.location}, status=${test.status}');
    debugPrint('🧪 Test description: ${test.description}');

    setState(() {
      _existingTest = test;
      _photographerNameController.text = test.title;
      _locationController.text = test.location ?? '';
      _status = test.status;
      _date = test.date;

      // Parse description to extract fields
      final description = test.description ?? '';
      final lines = description.split('\n\n');

      for (final line in lines) {
        if (line.startsWith('Test Type: ')) {
          _testType = line.substring(11).toLowerCase();
          debugPrint('🧪 Parsed test type: $_testType');
        } else if (line.startsWith('Rate: ')) {
          _rateController.text = line.substring(6);
          debugPrint('🧪 Parsed rate: ${_rateController.text}');
        } else if (line.startsWith('Call Time: ')) {
          final timeString = line.substring(11);
          _callTimeController.text = timeString;
          // Try to parse the time string back to TimeOfDay
          try {
            // Handle different time formats (12-hour and 24-hour)
            if (timeString.contains('AM') || timeString.contains('PM')) {
              // 12-hour format parsing
              final cleanTime = timeString.replaceAll(RegExp(r'[^\d:]'), '');
              final parts = cleanTime.split(':');
              if (parts.length >= 2) {
                int hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                if (timeString.contains('PM') && hour != 12) hour += 12;
                if (timeString.contains('AM') && hour == 12) hour = 0;
                _callTime = TimeOfDay(hour: hour, minute: minute);
              }
            } else {
              // 24-hour format parsing
              final parts = timeString.split(':');
              if (parts.length >= 2) {
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                _callTime = TimeOfDay(hour: hour, minute: minute);
              }
            }
          } catch (e) {
            debugPrint('🧪 Could not parse time: $timeString');
          }
          debugPrint('🧪 Parsed call time: ${_callTimeController.text}');
        } else if (line.startsWith('Notes: ')) {
          _notesController.text = line.substring(7);
          debugPrint('🧪 Parsed notes: ${_notesController.text}');
        }
      }
    });

    debugPrint('🧪 Form initialized, triggering setState');
  }

  @override
  void dispose() {
    _photographerNameController.dispose();
    _rateController.dispose();
    _callTimeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final testData = {
        'title': _photographerNameController.text,
        'description': _buildDescriptionString(),
        'date': _date.toIso8601String(),
        'location': _locationController.text,
        'requirements': '',
        'status': _status,
        'rate': _testType == 'paid' ? double.tryParse(_rateController.text) : null,
        'currency': 'USD',
        'images': [],
      };

      debugPrint('🧪 Saving test with data: $testData');
      debugPrint('🧪 Is editing: $_isEditing');

      if (_isEditing) {
        debugPrint('🧪 Updating test with ID: ${_existingTest!.id}');
        await Test.update(_existingTest!.id, testData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        debugPrint('🧪 Creating new test');
        await Test.create(testData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test created successfully')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to ${_isEditing ? 'update' : 'create'} test: $e';
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
    return AppLayout(
      currentPage: '/new-test',
      title: _isEditing ? 'Edit Test' : 'New Test',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photographer Name
              ui.Input(
                label: 'Photographer Name *',
                controller: _photographerNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter photographer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Test Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Test Type *',
                  border: OutlineInputBorder(),
                ),
                value: _testTypes.contains(_testType) ? _testType : null,
                items: _testTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _testType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select test type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rate (only if paid)
              if (_testType == 'paid') ...[
                ui.Input(
                  label: 'Rate *',
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_testType == 'paid' && (value == null || value.isEmpty)) {
                      return 'Please enter rate for paid test';
                    }
                    if (value != null && value.isNotEmpty) {
                      final rate = double.tryParse(value);
                      if (rate == null) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

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

              // Call Time
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Call Time *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _callTime.format(context),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _callTime,
                  );
                  if (time != null) {
                    setState(() {
                      _callTime = time;
                      _callTimeController.text = time.format(context);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select call time';
                  }
                  return null;
                },
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
                value: _statuses.contains(_status) ? _status : 'pending',
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
                  text: _isEditing ? 'Update Test' : 'Create Test',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _saveTest,
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

    parts.add('Test Type: ${_testType[0].toUpperCase()}${_testType.substring(1)}');

    if (_testType == 'paid' && _rateController.text.trim().isNotEmpty) {
      parts.add('Rate: ${_rateController.text.trim()}');
    }

    if (_callTimeController.text.trim().isNotEmpty) {
      parts.add('Call Time: ${_callTimeController.text.trim()}');
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
