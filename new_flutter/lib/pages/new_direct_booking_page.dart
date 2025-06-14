import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:new_flutter/services/direct_bookings_service.dart';
import 'package:new_flutter/models/direct_booking.dart';

// Class to handle multi-day scheduling
class DaySchedule {
  final DateTime date;
  final TimeOfDay? callTime;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  DaySchedule({
    required this.date,
    this.callTime,
    this.startTime,
    this.endTime,
  });

  DaySchedule copyWith({
    DateTime? date,
    TimeOfDay? callTime,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return DaySchedule(
      date: date ?? this.date,
      callTime: callTime ?? this.callTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class NewDirectBookingPage extends StatefulWidget {
  final DirectBooking? editingBooking;

  const NewDirectBookingPage({super.key, this.editingBooking});

  @override
  State<NewDirectBookingPage> createState() => _NewDirectBookingPageState();
}

class _NewDirectBookingPageState extends State<NewDirectBookingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _clientNameController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _usageRateController = TextEditingController();
  final _locationController = TextEditingController();
  final _agencyFeeController = TextEditingController();
  final _taxController = TextEditingController();
  final _extraHoursController = TextEditingController();
  final _notesController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Form state
  String _selectedCurrency = 'USD';
  String _selectedJobStatus = 'Completed';
  String _selectedPaymentStatus = 'Unpaid';
  String? _selectedAgentId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isDateRange = false;
  bool _isEditing = false;
  final List<PlatformFile> _selectedFiles = [];

  // Multi-day scheduling support
  final List<DaySchedule> _daySchedules = [];

  // Options
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'PLN', 'ILS', 'JPY', 'KRW', 'CNY', 'AUD'];
  final List<String> _jobStatuses = ['Completed', 'Canceled'];
  final List<String> _paymentStatuses = ['Unpaid', 'Paid', 'Partial', 'Pending'];
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

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editingBooking != null;

    if (_isEditing && widget.editingBooking != null) {
      // Use post-frame callback to ensure form population happens after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFormWithBooking(widget.editingBooking!);
      });
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _startDateController.text = DateFormat('MM/dd/yyyy').format(_startDate!);
      _endDateController.text = DateFormat('MM/dd/yyyy').format(_endDate!);

      // Initialize with single day schedule
      _daySchedules.add(DaySchedule(date: DateTime.now()));
    }
  }

  void _populateFormWithBooking(DirectBooking booking) {
    debugPrint('🔍 Populating form with booking: ${booking.id}');
    debugPrint('🔍 Client Name: ${booking.clientName}');
    debugPrint('🔍 Booking Type: ${booking.bookingType}');
    debugPrint('🔍 Location: ${booking.location}');
    debugPrint('🔍 Rate: ${booking.rate}');
    debugPrint('🔍 Date: ${booking.date}');
    debugPrint('🔍 Time: ${booking.time}');
    debugPrint('🔍 End Time: ${booking.endTime}');

    _clientNameController.text = booking.clientName;
    _jobTypeController.text = booking.bookingType ?? '';
    _locationController.text = booking.location ?? '';
    _selectedAgentId = booking.bookingAgent;
    _dayRateController.text = booking.rate?.toString() ?? '';
    _agencyFeeController.text = booking.agencyFeePercentage ?? '';
    _taxController.text = booking.taxPercentage ?? '';
    _extraHoursController.text = booking.extraHours ?? '';
    _notesController.text = booking.notes ?? '';
    _selectedCurrency = booking.currency ?? 'USD';
    _selectedJobStatus = booking.status ?? 'scheduled';
    _selectedPaymentStatus = booking.paymentStatus ?? 'unpaid';

    if (booking.date != null) {
      _startDate = booking.date;
      _startDateController.text = DateFormat('MM/dd/yyyy').format(booking.date!);
      _endDate = booking.date;
      _endDateController.text = DateFormat('MM/dd/yyyy').format(booking.date!);

      // Initialize with single day schedule for the booking date
      _daySchedules.clear();

      // Parse time fields if available
      TimeOfDay? startTime;
      TimeOfDay? endTime;

      if (booking.time != null && booking.time!.isNotEmpty) {
        startTime = _parseTimeString(booking.time!);
      }

      if (booking.endTime != null && booking.endTime!.isNotEmpty) {
        endTime = _parseTimeString(booking.endTime!);
      }

      _daySchedules.add(DaySchedule(
        date: booking.date!,
        startTime: startTime,
        endTime: endTime,
      ));
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _startDateController.text = DateFormat('MM/dd/yyyy').format(_startDate!);
      _endDateController.text = DateFormat('MM/dd/yyyy').format(_endDate!);
      _daySchedules.add(DaySchedule(date: DateTime.now()));
    }

    debugPrint('🔍 Form populated, triggering setState');
    setState(() {}); // Ensure UI updates after form population
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      // Handle different time formats
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1].split(' ')[0]); // Remove AM/PM if present

          // Handle AM/PM format
          if (timeString.toUpperCase().contains('PM') && hour != 12) {
            hour += 12;
          } else if (timeString.toUpperCase().contains('AM') && hour == 12) {
            hour = 0;
          }

          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      debugPrint('Error parsing time string "$timeString": $e');
    }
    return null;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _jobTypeController.dispose();
    _dayRateController.dispose();
    _usageRateController.dispose();
    _locationController.dispose();
    _agencyFeeController.dispose();
    _taxController.dispose();
    _extraHoursController.dispose();
    _notesController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare booking data
      final bookingData = {
        'client_name': _clientNameController.text,
        'booking_type': _jobTypeController.text.isEmpty ? null : _jobTypeController.text,
        'location': _locationController.text.isEmpty ? null : _locationController.text,
        'booking_agent': _selectedAgentId,
        'date': _startDate?.toIso8601String().split('T')[0], // Date only
        'time': _daySchedules.isNotEmpty && _daySchedules.first.startTime != null
            ? _formatTimeOfDay(_daySchedules.first.startTime!) : null,
        'end_time': _daySchedules.isNotEmpty && _daySchedules.first.endTime != null
            ? _formatTimeOfDay(_daySchedules.first.endTime!) : null,
        'rate': double.tryParse(_dayRateController.text),
        'currency': _selectedCurrency,
        'agency_fee_percentage': _agencyFeeController.text.isEmpty ? null : _agencyFeeController.text,
        'tax_percentage': _taxController.text.isEmpty ? null : _taxController.text,
        'extra_hours': _extraHoursController.text.isEmpty ? null : _extraHoursController.text,
        'status': _selectedJobStatus,
        'payment_status': _selectedPaymentStatus,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'files': _selectedFiles.isNotEmpty ? _selectedFiles.map((file) => {
          'name': file.name,
          'size': file.size,
          'path': file.path,
        }).toList() : null,
      };

      // Create or update the booking using the service
      final DirectBooking? result;
      if (_isEditing && widget.editingBooking?.id != null) {
        result = await DirectBookingsService.update(widget.editingBooking!.id!, bookingData);
      } else {
        result = await DirectBookingsService.create(bookingData);
      }

      if (result != null && mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Direct booking updated successfully!'
                : 'Direct booking created successfully!'),
            backgroundColor: AppTheme.goldColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Failed to update booking. Please try again.'
                : 'Failed to create booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Error updating booking: $error'
                : 'Error creating booking: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: _isEditing ? '/edit-direct-booking' : '/new-direct-booking',
      title: _isEditing ? 'Edit Direct Booking' : 'Add New Direct Booking',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 1200 ? 1200 : double.infinity,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildScheduleSection(),
                const SizedBox(height: 24),
                _buildFinancialSection(),
                const SizedBox(height: 24),
                _buildFilesSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      'Basic Information',
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _clientNameController,
                label: 'Client Name',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'Job Type',
                value: _jobTypeController.text.isEmpty ? null : _jobTypeController.text,
                items: _jobTypes,
                onChanged: (value) {
                  _jobTypeController.text = value ?? '';
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _locationController,
          label: 'Location',
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
    );
  }

  Widget _buildScheduleSection() {
    return _buildSectionCard(
      'Schedule',
      [
        _buildDateRangeSection(),
        const SizedBox(height: 16),
        _buildMultiDaySchedule(),
      ],
    );
  }

  Widget _buildMultiDaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ..._daySchedules.asMap().entries.map((entry) {
          final index = entry.key;
          final daySchedule = entry.value;
          return _buildDayScheduleCard(index, daySchedule);
        }),
      ],
    );
  }

  Widget _buildDayScheduleCard(int index, DaySchedule daySchedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${index + 1} - ${DateFormat('MMM dd, yyyy').format(daySchedule.date)}',
            style: const TextStyle(
              color: AppTheme.goldColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Stack vertically on small screens
                return Column(
                  children: [
                    _buildTimeFieldForDay('Call Time', daySchedule.callTime, (time) {
                      _updateDayScheduleTime(index, callTime: time);
                    }),
                    const SizedBox(height: 8),
                    _buildTimeFieldForDay('Start Time', daySchedule.startTime, (time) {
                      _updateDayScheduleTime(index, startTime: time);
                    }),
                    const SizedBox(height: 8),
                    _buildTimeFieldForDay('End Time', daySchedule.endTime, (time) {
                      _updateDayScheduleTime(index, endTime: time);
                    }),
                  ],
                );
              } else {
                // Row layout for larger screens
                return Row(
                  children: [
                    Expanded(
                      child: _buildTimeFieldForDay('Call Time', daySchedule.callTime, (time) {
                        _updateDayScheduleTime(index, callTime: time);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeFieldForDay('Start Time', daySchedule.startTime, (time) {
                        _updateDayScheduleTime(index, startTime: time);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeFieldForDay('End Time', daySchedule.endTime, (time) {
                        _updateDayScheduleTime(index, endTime: time);
                      }),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateDaySchedules() {
    if (_startDate == null) return;

    _daySchedules.clear();

    if (_isDateRange && _endDate != null) {
      DateTime current = _startDate!;
      while (current.isBefore(_endDate!) || current.isAtSameMomentAs(_endDate!)) {
        _daySchedules.add(DaySchedule(date: current));
        current = current.add(const Duration(days: 1));
      }
    } else {
      _daySchedules.add(DaySchedule(date: _startDate!));
    }
  }

  void _updateDayScheduleTime(int index, {TimeOfDay? callTime, TimeOfDay? startTime, TimeOfDay? endTime}) {
    if (index < _daySchedules.length) {
      setState(() {
        _daySchedules[index] = _daySchedules[index].copyWith(
          callTime: callTime ?? _daySchedules[index].callTime,
          startTime: startTime ?? _daySchedules[index].startTime,
          endTime: endTime ?? _daySchedules[index].endTime,
        );
      });
    }
  }

  Widget _buildTimeFieldForDay(String label, TimeOfDay? time, Function(TimeOfDay) onTimeSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppTheme.goldColor,
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
              onTimeSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3E3E3E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    time != null ? _formatTimeOfDay(time) : '--:--',
                    style: TextStyle(
                      color: time != null ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDateField(String label, TextEditingController controller, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'MM/DD/YYYY',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.goldColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppTheme.goldColor,
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
              onDateSelected(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Date Range',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Switch(
              value: _isDateRange,
              onChanged: (value) {
                setState(() {
                  _isDateRange = value;
                  if (!value) {
                    _endDate = _startDate;
                    _endDateController.text = _startDateController.text;
                    // Reset to single day
                    _daySchedules.clear();
                    if (_startDate != null) {
                      _daySchedules.add(DaySchedule(date: _startDate!));
                    }
                  }
                });
              },
              activeColor: AppTheme.goldColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600 && _isDateRange) {
              // Stack vertically on small screens when date range is enabled
              return Column(
                children: [
                  _buildDateField('Start Date', _startDateController, _startDate, (date) {
                    setState(() {
                      _startDate = date;
                      _startDateController.text = DateFormat('MM/dd/yyyy').format(date);
                      _updateDaySchedules();
                    });
                  }),
                  const SizedBox(height: 16),
                  if (_isDateRange)
                    _buildDateField('End Date', _endDateController, _endDate, (date) {
                      setState(() {
                        _endDate = date;
                        _endDateController.text = DateFormat('MM/dd/yyyy').format(date);
                        _updateDaySchedules();
                      });
                    }),
                ],
              );
            } else {
              // Row layout for larger screens or single date
              return Row(
                children: [
                  Expanded(
                    child: _buildDateField('Start Date', _startDateController, _startDate, (date) {
                      setState(() {
                        _startDate = date;
                        _startDateController.text = DateFormat('MM/dd/yyyy').format(date);
                        _updateDaySchedules();
                      });
                    }),
                  ),
                  if (_isDateRange) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField('End Date', _endDateController, _endDate, (date) {
                        setState(() {
                          _endDate = date;
                          _endDateController.text = DateFormat('MM/dd/yyyy').format(date);
                          _updateDaySchedules();
                        });
                      }),
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return _buildSectionCard(
      'Financial Details',
      [
        // Rates section
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildTextField(
                    controller: _dayRateController,
                    label: 'Day Rate',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Currency',
                    value: _selectedCurrency,
                    items: _currencies,
                    onChanged: (value) => setState(() => _selectedCurrency = value!),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dayRateController,
                      label: 'Day Rate',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Currency',
                      value: _selectedCurrency,
                      items: _currencies,
                      onChanged: (value) => setState(() => _selectedCurrency = value!),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _usageRateController,
          label: 'Usage Rate (optional)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // Extra hours (only in edit mode)
        if (_isEditing) ...[
          _buildTextField(
            controller: _extraHoursController,
            label: 'Extra Hours',
            keyboardType: TextInputType.number,
            placeholder: '0.0',
          ),
          const SizedBox(height: 4),
          const Text(
            'Extra hours calculated at 150% of base rate',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 16),
        ],
        // Agency fee and tax
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildTextField(
                    controller: _agencyFeeController,
                    label: 'Agency Fee %',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _taxController,
                    label: 'Tax % (from model salary after agency fee deduction)',
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _agencyFeeController,
                      label: 'Agency Fee %',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _taxController,
                      label: 'Tax % (from model salary after agency fee deduction)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        // Status fields
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildDropdownField(
                    label: 'Job Status',
                    value: _selectedJobStatus,
                    items: _jobStatuses,
                    onChanged: (value) => setState(() => _selectedJobStatus = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Payment Status',
                    value: _selectedPaymentStatus,
                    items: _paymentStatuses,
                    onChanged: (value) => setState(() => _selectedPaymentStatus = value!),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Job Status',
                      value: _selectedJobStatus,
                      items: _jobStatuses,
                      onChanged: (value) => setState(() => _selectedJobStatus = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Payment Status',
                      value: _selectedPaymentStatus,
                      items: _paymentStatuses,
                      onChanged: (value) => setState(() => _selectedPaymentStatus = value!),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilesSection() {
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

  Widget _buildNotesSection() {
    return _buildSectionCard(
      'Additional Notes',
      [
        _buildTextField(
          controller: _notesController,
          label: 'Notes',
          maxLines: 4,
          placeholder: 'Add any additional notes or requirements...',
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.goldColor,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? placeholder,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.goldColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value != null && items.contains(value) ? value : null,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF2A2A2A),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.goldColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
                    _isEditing ? 'Update Booking' : 'Create Booking',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
