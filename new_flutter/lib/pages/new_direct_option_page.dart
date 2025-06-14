import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/models/event.dart';

import 'package:new_flutter/services/direct_options_service.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class NewDirectOptionPage extends StatefulWidget {
  const NewDirectOptionPage({super.key});

  @override
  State<NewDirectOptionPage> createState() => _NewDirectOptionPageState();
}

class _NewDirectOptionPageState extends State<NewDirectOptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _usageRateController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _agencyFeeController = TextEditingController();
  final _transferToDirectBookingController = TextEditingController();

  String _selectedOptionType = '';
  OptionStatus _selectedOptionStatus = OptionStatus.pending;
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  String? _selectedAgentId;
  bool _isCustomType = false;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingId;
  final List<PlatformFile> _selectedFiles = [];

  final List<String> _optionTypes = [
    'Add manually',
    'Commercial',
    'Editorial',
    'Fashion Show',
    'Lookbook',
    'Print',
    'Runway',
    'Social Media',
    'Web Content',
    'Other'
  ];

  // Status options are now handled by OptionStatus enum

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
          _loadDirectOption(args);
        }
      }
    });
  }

  void _loadInitialData(Map<String, dynamic> data) {
    setState(() {
      _clientNameController.text = data['clientName'] ?? '';
      _selectedDate = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
      _locationController.text = data['location'] ?? '';
      _dayRateController.text = data['dayRate'] ?? '';
      _usageRateController.text = data['usageRate'] ?? '';
      _selectedCurrency = data['currency'] ?? 'USD';
      _notesController.text = data['notes'] ?? '';
      _selectedAgentId = data['bookingAgent'];
      if (data['jobType'] != null && data['jobType'].isNotEmpty) {
        if (_optionTypes.contains(data['jobType'])) {
          _selectedOptionType = data['jobType'];
        } else {
          _selectedOptionType = 'Add manually';
          _isCustomType = true;
          _customTypeController.text = data['jobType'];
        }
      }
    });
  }

  Future<void> _loadDirectOption(String id) async {
    setState(() {
      _isLoading = true;
      _isEditing = true;
      _editingId = id;
    });

    try {
      final option = await DirectOptionsService.getById(id);
      if (option != null) {
        setState(() {
          _clientNameController.text = option.clientName;
          _selectedOptionType = option.optionType ?? '';
          _locationController.text = option.location ?? '';
          _dayRateController.text = option.rate?.toString() ?? '';
          _selectedDate = option.date ?? DateTime.now();
          _notesController.text = option.notes ?? '';
          // Convert status string to OptionStatus enum
          _selectedOptionStatus = OptionStatus.values.firstWhere(
            (status) => status.toString().split('.').last == option.status,
            orElse: () => OptionStatus.pending,
          );
          _selectedCurrency = option.currency ?? 'USD';
          _agencyFeeController.text = option.agencyFeePercentage ?? '';
          _selectedAgentId = option.bookingAgent;

          // Handle custom type
          if (_selectedOptionType.isNotEmpty &&
              !_optionTypes.contains(_selectedOptionType)) {
            _customTypeController.text = _selectedOptionType;
            _selectedOptionType = 'Add manually';
            _isCustomType = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading direct option: $e'),
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
    _locationController.dispose();
    _dayRateController.dispose();
    _usageRateController.dispose();
    _notesController.dispose();
    _customTypeController.dispose();
    _agencyFeeController.dispose();
    _transferToDirectBookingController.dispose();
    super.dispose();
  }

  // Time-related methods removed as they're not needed for direct options

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

  // File handling methods
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final optionData = {
        'client_name': _clientNameController.text,
        'option_type':
            _isCustomType ? _customTypeController.text : _selectedOptionType,
        'day_rate': double.tryParse(_dayRateController.text),
        'usage_rate': double.tryParse(_usageRateController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'location': _locationController.text,
        'booking_agent': _selectedAgentId,
        'option_status': _selectedOptionStatus.toString().split('.').last,
        'currency': _selectedCurrency,
        'notes': _notesController.text,
        'agency_fee_percentage': _agencyFeeController.text,
        if (_isEditing) 'transfer_to_direct_booking': _transferToDirectBookingController.text,
      };

      if (_isEditing && _editingId != null) {
        final result = await DirectOptionsService.update(_editingId!, optionData);
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Direct option updated successfully!'),
              backgroundColor: AppTheme.goldColor,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (mounted) {
          throw Exception('Failed to update direct option');
        }
      } else {
        final result = await DirectOptionsService.create(optionData);
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Direct option created successfully!'),
              backgroundColor: AppTheme.goldColor,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (mounted) {
          throw Exception('Failed to create direct option');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving direct option: $e'),
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
        currentPage: '/new-direct-option',
        title: _isEditing ? 'Edit Direct Option' : 'New Direct Option',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppLayout(
      currentPage: '/new-direct-option',
      title: _isEditing ? 'Edit Direct Option' : 'New Direct Option',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
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
                  _buildOptionTypeField(),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Location',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 16),
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

              // Rates and Status Section
              _buildSectionCard(
                'Rates and Status',
                [
                  _buildRateFields(),
                  const SizedBox(height: 16),
                  _buildOptionStatusField(),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    ui.Input(
                      label: 'Transfer to Direct Booking',
                      controller: _transferToDirectBookingController,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Agency Fee (%)',
                    controller: _agencyFeeController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Files Section
              _buildFileUploadSection(),
              const SizedBox(height: 24),

              // Notes Section
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
                          : (_isEditing ? 'Update Option' : 'Create Option'),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust padding based on available width
        final isSmallScreen = constraints.maxWidth < 400;
        final padding = isSmallScreen ? 12.0 : 20.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Option Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_isCustomType)
          Row(
            children: [
              Expanded(
                child: ui.Input(
                  label: 'Custom Option Type',
                  controller: _customTypeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter option type';
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
                    _customTypeController.clear();
                  });
                },
                text: 'Cancel',
                variant: ButtonVariant.outline,
              ),
            ],
          )
        else
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedOptionType.isNotEmpty && _optionTypes.contains(_selectedOptionType)
                  ? _selectedOptionType
                  : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Select option type',
                style: TextStyle(color: Colors.white70),
              ),
              items: _optionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == 'Add manually') {
                  setState(() {
                    _isCustomType = true;
                    _selectedOptionType = '';
                  });
                } else {
                  setState(() {
                    _selectedOptionType = value ?? '';
                  });
                }
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

  Widget _buildRateFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ui.Input(
                label: 'Day Rate',
                controller: _dayRateController,
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
                      value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : 'USD',
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
        ),
        const SizedBox(height: 16),
        ui.Input(
          label: 'Usage Rate (optional)',
          controller: _usageRateController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildOptionStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Option Status',
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
          child: DropdownButtonFormField<OptionStatus>(
            value: _selectedOptionStatus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: OptionStatus.values.map((status) {
              return DropdownMenuItem<OptionStatus>(
                value: status,
                child: Text(
                  status.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOptionStatus = value ?? OptionStatus.pending;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return _buildSectionCard(
      'Files',
      [
        Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Files',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.add),
              label: const Text('Add Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldColor,
                foregroundColor: Colors.black,
              ),
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
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(file.extension ?? ''),
                    size: 20,
                    color: Colors.grey[400],
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(file.size / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
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
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
