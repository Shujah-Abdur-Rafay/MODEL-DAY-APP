import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/models/ai_job.dart';
import 'package:new_flutter/services/ai_jobs_service.dart';
import 'package:intl/intl.dart';

class NewAiJobPage extends StatefulWidget {
  const NewAiJobPage({super.key});

  @override
  State<NewAiJobPage> createState() => _NewAiJobPageState();
}

class _NewAiJobPageState extends State<NewAiJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedAgentId;

  String _selectedType = 'text_to_image';
  String _selectedStatus = 'pending';
  String _selectedPaymentStatus = 'unpaid';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingId;

  final List<String> _aiJobTypes = [
    'text_to_image',
    'image_to_image',
    'video_generation',
    'voice_cloning',
    'avatar_creation',
    'virtual_modeling',
    'ai_photography',
    'deepfake_modeling'
  ];

  final List<String> _statusOptions = [
    'pending',
    'in_progress',
    'completed',
    'canceled'
  ];

  final List<String> _paymentStatusOptions = [
    'unpaid',
    'paid',
    'partial',
    'pending'
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'PLN',
    'ILS',
    'JPY',
    'KRW',
    'CNY',
    'AUD'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is Map<String, dynamic>) {
          _loadInitialData(args);
        } else if (args is String) {
          _loadAiJob(args);
        } else if (args is AiJob) {
          // Handle AiJob object directly
          _loadAiJobFromObject(args);
        }
      }
    });
  }

  void _loadInitialData(Map<String, dynamic> data) {
    setState(() {
      _clientNameController.text = data['clientName'] ?? '';
      _selectedDate = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
      if (data['startTime'] != null && data['startTime'].isNotEmpty) {
        final timeParts = data['startTime'].split(':');
        _startTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
      if (data['endTime'] != null && data['endTime'].isNotEmpty) {
        final timeParts = data['endTime'].split(':');
        _endTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
      _locationController.text = data['location'] ?? '';
      _rateController.text = data['rate'] ?? '';
      _selectedCurrency = data['currency'] ?? 'USD';
      _notesController.text = data['notes'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _selectedAgentId = data['bookingAgent'];
      if (data['type'] != null && _aiJobTypes.contains(data['type'])) {
        _selectedType = data['type'];
      }
    });
  }

  void _loadAiJobFromObject(AiJob aiJob) {
    setState(() {
      _isEditing = true;
      _editingId = aiJob.id;
      _clientNameController.text = aiJob.clientName;
      _selectedType = aiJob.type ?? 'text_to_image';
      _descriptionController.text = aiJob.description ?? '';
      _locationController.text = aiJob.location ?? '';
      _selectedAgentId = aiJob.bookingAgent;
      _selectedDate = aiJob.date ?? DateTime.now();
      _rateController.text = aiJob.rate?.toString() ?? '';
      _notesController.text = aiJob.notes ?? '';
      _selectedStatus = aiJob.status ?? 'pending';
      _selectedPaymentStatus = aiJob.paymentStatus ?? 'unpaid';
      _selectedCurrency = aiJob.currency ?? 'USD';

      // Parse time string
      if (aiJob.time != null && aiJob.time!.isNotEmpty) {
        final timeParts = aiJob.time!.split(':');
        _startTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    });
  }

  Future<void> _loadAiJob(String id) async {
    setState(() {
      _isLoading = true;
      _isEditing = true;
      _editingId = id;
    });

    try {
      final aiJob = await AiJobsService.getById(id);
      if (aiJob != null) {
        _loadAiJobFromObject(aiJob);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading AI job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('🤖 NewAiJobPage._handleSubmit() - Starting submit...');
    setState(() {
      _isLoading = true;
    });

    try {
      final aiJob = AiJob(
        id: _editingId,
        clientName: _clientNameController.text,
        type: _selectedType,
        description: _descriptionController.text,
        location: _locationController.text,
        bookingAgent: _selectedAgentId,
        date: _selectedDate,
        time: _formatTime(_startTime),
        rate: double.tryParse(_rateController.text),
        currency: _selectedCurrency,
        notes: _notesController.text,
        status: _selectedStatus,
        paymentStatus: _selectedPaymentStatus,
      );

      debugPrint('🤖 NewAiJobPage._handleSubmit() - AI job data: ${aiJob.toJson()}');

      if (_isEditing && _editingId != null) {
        debugPrint('🤖 NewAiJobPage._handleSubmit() - Updating AI job with ID: $_editingId');
        await AiJobsService.update(_editingId!, aiJob.toJson());
      } else {
        debugPrint('🤖 NewAiJobPage._handleSubmit() - Creating new AI job');
        await AiJobsService.create(aiJob.toJson());
      }

      debugPrint('🤖 NewAiJobPage._handleSubmit() - AI job saved successfully');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ NewAiJobPage._handleSubmit() - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving AI job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditing) {
      return AppLayout(
        currentPage: '/new-ai-job',
        title: _isEditing ? 'Edit AI Job' : 'New AI Job',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppLayout(
      currentPage: '/new-ai-job',
      title: _isEditing ? 'Edit AI Job' : 'New AI Job',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionCard(
                'Basic Information',
                [
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
                  const SizedBox(height: 16),
                  _buildAiJobTypeField(),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Location',
                    controller: _locationController,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scheduling
              _buildSectionCard(
                'Scheduling',
                [
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTimeField(),
                  const SizedBox(height: 16),
                  _buildStatusField(),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Information
              _buildSectionCard(
                'Payment Information',
                [
                  _buildRateField(),
                  const SizedBox(height: 16),
                  _buildPaymentStatusField(),
                ],
              ),
              const SizedBox(height: 24),

              // Agent Information
              _buildSectionCard(
                'Agent Information',
                [
                  AgentDropdown(
                    selectedAgentId: _selectedAgentId,
                    labelText: 'Booking Agent',
                    hintText: 'Select an agent',
                    onChanged: (value) {
                      setState(() {
                        _selectedAgentId = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              _buildSectionCard(
                'Notes',
                [
                  ui.Input(
                    label: 'Notes',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Buttons
              Row(
                children: [
                  Expanded(
                    child: Button(
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Button(
                      onPressed: _isLoading ? null : _handleSubmit,
                      text: _isLoading
                          ? 'Saving...'
                          : (_isEditing ? 'Update AI Job' : 'Create AI Job'),
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

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAiJobTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Job Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: DropdownButtonFormField<String>(
            value: _aiJobTypes.contains(_selectedType) ? _selectedType : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _aiJobTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value ?? 'text_to_image';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Time',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  _startTime != null ? _formatTime(_startTime) : 'Select time',
                  style: TextStyle(
                    color: _startTime != null ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: DropdownButtonFormField<String>(
            value: _statusOptions.contains(_selectedStatus) ? _selectedStatus : _statusOptions.first,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _statusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? 'pending';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRateField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ui.Input(
            label: 'Rate',
            controller: _rateController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Currency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : _currencies.first,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value ?? 'USD';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: DropdownButtonFormField<String>(
            value: _paymentStatusOptions.contains(_selectedPaymentStatus) ? _selectedPaymentStatus : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _paymentStatusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentStatus = value ?? 'unpaid';
              });
            },
          ),
        ),
      ],
    );
  }
}
