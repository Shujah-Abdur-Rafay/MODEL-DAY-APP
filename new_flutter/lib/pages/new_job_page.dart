import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_flutter/models/job.dart';
import 'package:new_flutter/services/jobs_service.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/safe_dropdown.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class NewJobPage extends StatefulWidget {
  final Job? job; // For editing existing job

  const NewJobPage({super.key, this.job});

  @override
  State<NewJobPage> createState() => _NewJobPageState();
}

class _NewJobPageState extends State<NewJobPage> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information Controllers
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _customJobTypeController = TextEditingController();

  // Financial Controllers
  final _rateController = TextEditingController();
  final _usageController = TextEditingController();
  final _extraHoursController = TextEditingController();
  final _agencyFeeController = TextEditingController();
  final _taxController = TextEditingController();
  final _additionalFeesController = TextEditingController();

  // Form State
  DateTime _selectedDate = DateTime.now();
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedJobType = 'Add manually';
  String _selectedCurrency = 'USD';
  String _selectedStatus = 'Scheduled';
  String _selectedPaymentStatus = 'Unpaid';
  String? _selectedAgentId;
  final List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  bool _isCustomType = false;
  String? _error;

  // Job Types
  final List<String> _jobTypes = [
    'Add manually',
    'Advertising',
    'Campaign',
    'E-commerce',
    'Editorial',
    'Fittings',
    'Lookbook',
    'Looks',
    'Show',
    'Showroom',
    'TVC',
    'Web / Social Media Shooting',
    'TikTok',
    'AI',
    'Film'
  ];

  // Currencies
  final List<String> _currencies = [
    'USD',
    'EUR',
    'PLN',
    'ILS',
    'JPY',
    'KRW',
    'GBP',
    'CNY',
    'AUD'
  ];

  // Status Options
  final List<String> _statusOptions = [
    'Scheduled',
    'In Progress',
    'Completed',
    'Canceled'
  ];

  final List<String> _paymentStatusOptions = [
    'Unpaid',
    'Partially Paid',
    'Paid'
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 NewJobPage.initState() - job: ${widget.job?.id}');
    if (widget.job != null) {
      debugPrint('📝 Loading job data for editing: ${widget.job!.clientName}');
      _loadJobData();
    } else {
      debugPrint('➕ Creating new job');
      _handlePreselectedDate();
    }
  }

  void _handlePreselectedDate() {
    // Handle preselected date from calendar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('preselectedDate')) {
        final preselectedDate = args['preselectedDate'] as DateTime?;
        if (preselectedDate != null) {
          setState(() {
            _selectedDate = preselectedDate;
          });
          debugPrint('📅 Preselected date set: ${preselectedDate.toString()}');
        }
      }
    });
  }

  void _loadJobData() {
    final job = widget.job!;

    // Load basic information
    _clientNameController.text = job.clientName;
    _locationController.text = job.location;
    _notesController.text = job.notes ?? '';

    // Load job type
    if (_jobTypes.contains(job.type)) {
      _selectedJobType = job.type;
      _isCustomType = false;
    } else {
      _customJobTypeController.text = job.type;
      _isCustomType = true;
      _selectedJobType = '';
    }

    // Load dates and times
    if (job.date.isNotEmpty) {
      _selectedDate = DateTime.parse(job.date);
    }
    if (job.time != null && job.time!.isNotEmpty) {
      final timeParts = job.time!.split(':');
      if (timeParts.length == 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }
    if (job.endTime != null && job.endTime!.isNotEmpty) {
      final timeParts = job.endTime!.split(':');
      if (timeParts.length == 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }

    // Load financial information
    _rateController.text = job.rate.toString();
    _extraHoursController.text = job.extraHours?.toString() ?? '';
    _agencyFeeController.text = job.agencyFeePercentage?.toString() ?? '';
    _taxController.text = job.taxPercentage?.toString() ?? '';

    // Load other fields
    _selectedCurrency = job.currency ?? 'USD';
    _selectedStatus = job.status ?? 'Scheduled';
    _selectedPaymentStatus = job.paymentStatus ?? 'Unpaid';
    _selectedAgentId = job.bookingAgent;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _customJobTypeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _rateController.dispose();
    _usageController.dispose();
    _extraHoursController.dispose();
    _agencyFeeController.dispose();
    _taxController.dispose();
    _additionalFeesController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Duration? _calculateDuration() {
    if (_startTime == null || _endTime == null) return null;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    // Handle overnight duration
    final durationMinutes = endMinutes >= startMinutes
        ? endMinutes - startMinutes
        : (24 * 60) - startMinutes + endMinutes;

    return Duration(minutes: durationMinutes);
  }

  double _calculateExtraHours() {
    final extraHours = double.tryParse(_extraHoursController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    return extraHours * (rate * 0.1); // 10% of rate per hour
  }

  double _calculateTotal() {
    final rate = double.tryParse(_rateController.text) ?? 0;
    final usage = double.tryParse(_usageController.text) ?? 0;
    final extraHours = _calculateExtraHours();
    final additionalFees = double.tryParse(_additionalFeesController.text) ?? 0;

    final subtotal = rate + usage + extraHours + additionalFees;
    final agencyFee =
        (double.tryParse(_agencyFeeController.text) ?? 0) / 100 * subtotal;
    final afterAgencyFee = subtotal - agencyFee;
    final tax =
        (double.tryParse(_taxController.text) ?? 0) / 100 * afterAgencyFee;

    return afterAgencyFee - tax;
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: Colors.white,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} $_selectedCurrency',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobData = {
        'client_name': _clientNameController.text,
        'type':
            _isCustomType ? _customJobTypeController.text : _selectedJobType,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'time': _formatTimeOfDay(_startTime),
        'end_time': _formatTimeOfDay(_endTime),
        'location': _locationController.text,
        'booking_agent': _selectedAgentId,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'currency': _selectedCurrency,
        'extra_hours': double.tryParse(_extraHoursController.text),
        'agency_fee_percentage': double.tryParse(_agencyFeeController.text),
        'tax_percentage': double.tryParse(_taxController.text),
        'status': _selectedStatus,
        'payment_status': _selectedPaymentStatus,
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      if (_endDate != null) {
        jobData['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }

      if (widget.job != null) {
        // Update existing job
        await JobsService.update(widget.job!.id!, jobData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Create new job
        await JobsService.create(jobData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job created successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      setState(() {
        _error = widget.job != null
            ? 'Failed to update job: $e'
            : 'Failed to create job: $e';
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
      currentPage: '/new-job',
      title: widget.job != null ? 'Edit Job' : 'New Job',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ui.Input(
                label: 'Client Name',
                controller: _clientNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Type Section
              const Text(
                'Job Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_isCustomType) ...[
                Row(
                  children: [
                    Expanded(
                      child: ui.Input(
                        controller: _customJobTypeController,
                        placeholder: 'Enter custom job type',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Job type is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Button(
                      onPressed: () {
                        setState(() {
                          _isCustomType = false;
                          _customJobTypeController.clear();
                        });
                      },
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                    ),
                  ],
                ),
              ] else ...[
                SafeDropdown(
                  value: _selectedJobType,
                  items: _jobTypes,
                  labelText: 'Job Type',
                  hintText: 'Select job type',
                  onChanged: (value) {
                    if (value == 'Add manually') {
                      setState(() {
                        _isCustomType = true;
                        _selectedJobType = '';
                      });
                    } else {
                      setState(() {
                        _selectedJobType = value ?? 'Add manually';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Job type is required';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMM d, yyyy').format(_selectedDate),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ui.Input(
                label: 'Location',
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ui.Input(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ui.Input(
                      label: 'Rate',
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final rate = double.tryParse(value);
                          if (rate == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SafeDropdown(
                      value: _selectedCurrency,
                      items: _currencies,
                      labelText: 'Currency',
                      hintText: 'Select currency',
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value ?? 'USD';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Time Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: _startTime != null
                            ? _formatTimeOfDay(_startTime)
                            : '',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            _endTime != null ? _formatTimeOfDay(_endTime) : '',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Duration Display
              if (_startTime != null && _endTime != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 24,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Duration: ${_calculateDuration()?.inHours}h ${(_calculateDuration()?.inMinutes ?? 0) % 60}m',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Agent Selection
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

              const SizedBox(height: 24),

              // Usage Rate
              TextFormField(
                controller: _usageController,
                decoration: const InputDecoration(
                  labelText: 'Usage rate (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),

              const SizedBox(height: 16),

              // Extra Hours
              TextFormField(
                controller: _extraHoursController,
                decoration: const InputDecoration(
                  labelText: 'Extra hours (calculated at 10% of rate per hour)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for calculation
                },
              ),

              const SizedBox(height: 16),

              // Agency Fee and Tax
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _agencyFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Agency Fee %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild for calculation
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild for calculation
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional Fees
              TextFormField(
                controller: _additionalFeesController,
                decoration: const InputDecoration(
                  labelText: 'Additional fees',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for calculation
                },
              ),

              const SizedBox(height: 24),

              // Status Fields
              Row(
                children: [
                  Expanded(
                    child: SafeDropdown(
                      value: _selectedStatus,
                      items: _statusOptions,
                      labelText: 'Status',
                      hintText: 'Select status',
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value ?? 'Scheduled';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SafeDropdown(
                      value: _selectedPaymentStatus,
                      items: _paymentStatusOptions,
                      labelText: 'Payment Status',
                      hintText: 'Select payment status',
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentStatus = value ?? 'Unpaid';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // File Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_file),
                        const SizedBox(width: 8),
                        const Text(
                          'Files',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Files'),
                        ),
                      ],
                    ),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...List.generate(_selectedFiles.length, (index) {
                        final file = _selectedFiles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(file.extension ?? ''),
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${(file.size / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeFile(index),
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        'No files selected. You can upload contracts, invoices, schedules, and other documents.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Financial Summary
              if (_rateController.text.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Day Rate',
                          double.tryParse(_rateController.text) ?? 0),
                      if (_usageController.text.isNotEmpty)
                        _buildSummaryRow('Usage',
                            double.tryParse(_usageController.text) ?? 0),
                      if (_extraHoursController.text.isNotEmpty)
                        _buildSummaryRow('Extra Hours', _calculateExtraHours()),
                      if (_additionalFeesController.text.isNotEmpty)
                        _buildSummaryRow(
                            'Additional Fees',
                            double.tryParse(_additionalFeesController.text) ??
                                0),
                      const Divider(),
                      _buildSummaryRow('Total', _calculateTotal(),
                          isTotal: true),
                    ],
                  ),
                ),
              ],

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
                  text: widget.job != null ? 'Update Job' : 'Create Job',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _createJob,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
