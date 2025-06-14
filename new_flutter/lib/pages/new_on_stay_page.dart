import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/on_stay.dart';
import 'package:new_flutter/services/on_stay_service.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:intl/intl.dart';

class NewOnStayPage extends StatefulWidget {
  final OnStay? stay; // For editing existing stays

  const NewOnStayPage({super.key, this.stay});

  @override
  State<NewOnStayPage> createState() => _NewOnStayPageState();
}

class _NewOnStayPageState extends State<NewOnStayPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _agencyNameController = TextEditingController();
  final _agencyAddressController = TextEditingController();
  final _locationController = TextEditingController();
  final _contractController = TextEditingController();
  final _flightCostController = TextEditingController();
  final _hotelAddressController = TextEditingController();
  final _hotelCostController = TextEditingController();
  final _pocketMoneyCostController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedAgentId;
  bool _hasPocketMoney = false;
  bool _loading = false;

  // No dropdown options needed for this simplified form

  @override
  void initState() {
    super.initState();
    // Handle both widget.stay and route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      debugPrint('🏨 NewOnStayPage initState - Arguments type: ${args.runtimeType}');
      debugPrint('🏨 NewOnStayPage initState - Widget stay: ${widget.stay}');

      if (args is OnStay) {
        debugPrint('🏨 NewOnStayPage initState - Populating from route arguments');
        _populateForm(args);
      } else if (widget.stay != null) {
        debugPrint('🏨 NewOnStayPage initState - Populating from widget stay');
        _populateForm(widget.stay!);
      } else {
        debugPrint('🏨 NewOnStayPage initState - No stay data to populate');
      }
    });
  }

  void _populateForm(OnStay stay) {
    debugPrint('🏨 Populating form with stay: ${stay.locationName} (${stay.id})');
    debugPrint('🏨 Stay data: location=${stay.locationName}, address=${stay.address}, cost=${stay.cost}');

    // Map existing OnStay fields to new form structure
    _locationController.text = stay.locationName;
    _hotelAddressController.text = stay.address ?? '';
    _startDate = stay.checkInDate;
    _endDate = stay.checkOutDate;
    _hotelCostController.text = stay.cost.toString();
    _notesController.text = stay.notes ?? '';

    // Set contact name if available
    if (stay.contactName != null && stay.contactName!.isNotEmpty) {
      _agencyNameController.text = stay.contactName!;
    }

    debugPrint('🏨 Form populated, triggering setState');
    setState(() {}); // Ensure UI updates after form population
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _agencyAddressController.dispose();
    _locationController.dispose();
    _contractController.dispose();
    _flightCostController.dispose();
    _hotelAddressController.dispose();
    _hotelCostController.dispose();
    _pocketMoneyCostController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isEditing = args is OnStay || widget.stay != null;

    return AppLayout(
      currentPage: '/new-on-stay',
      title: isEditing ? 'Edit Stay' : 'New Stay',
      child: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAgencySection(),
                const SizedBox(height: 24),
                _buildDatesSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildAgentSection(),
                const SizedBox(height: 24),
                _buildContractSection(),
                const SizedBox(height: 24),
                _buildFlightsSection(),
                const SizedBox(height: 24),
                _buildHotelSection(),
                const SizedBox(height: 24),
                _buildPocketMoneySection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencySection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agency Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Agency Name *',
              controller: _agencyNameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Agency name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Agency Address *',
              controller: _agencyAddressController,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Agency address is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('MMM d, yyyy').format(_startDate!)
                            : 'Select start date',
                        style: TextStyle(
                          color: _startDate != null ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('MMM d, yyyy').format(_endDate!)
                            : 'Select end date',
                        style: TextStyle(
                          color: _endDate != null ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Location *',
              controller: _locationController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }

  Widget _buildContractSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contract',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Contract Details',
              controller: _contractController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightsSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flights Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Flight Cost',
              controller: _flightCostController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hotel/Apartment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Hotel/Apartment Address *',
              controller: _hotelAddressController,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hotel/Apartment address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Hotel Cost',
              controller: _hotelCostController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPocketMoneySection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pocket Money',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _hasPocketMoney,
                  onChanged: (value) {
                    setState(() {
                      _hasPocketMoney = value ?? false;
                      if (!_hasPocketMoney) {
                        _pocketMoneyCostController.clear();
                      }
                    });
                  },
                ),
                const Text(
                  'Has Pocket Money',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            if (_hasPocketMoney) ...[
              const SizedBox(height: 16),
              ui.Input(
                label: 'Pocket Money Cost',
                controller: _pocketMoneyCostController,
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ui.Input(
              label: 'Notes',
              controller: _notesController,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isEditing = args is OnStay || widget.stay != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _loading ? null : _saveStay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(isEditing ? 'Update Stay' : 'Save Stay'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // If end date is before start date, clear it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveStay() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      // Map new form fields to existing OnStay model structure
      final data = {
        'location_name': _locationController.text.trim(),
        'stay_type': 'On Stay', // Fixed type for on stay
        'address': _hotelAddressController.text.trim().isEmpty
            ? null
            : _hotelAddressController.text.trim(),
        'check_in_date': _startDate?.toIso8601String().split('T')[0],
        'check_out_date': _endDate?.toIso8601String().split('T')[0],
        'check_in_time': null,
        'check_out_time': null,
        'cost': _hotelCostController.text.trim().isEmpty
            ? 0.0
            : double.tryParse(_hotelCostController.text) ?? 0.0,
        'currency': 'USD',
        'contact_name': _agencyNameController.text.trim().isEmpty
            ? null
            : _agencyNameController.text.trim(),
        'contact_phone': null,
        'contact_email': null,
        'status': 'confirmed',
        'payment_status': 'unpaid',
        'notes': _buildNotesString(),
      };

      final args = ModalRoute.of(context)?.settings.arguments;
      final editingStay = args is OnStay ? args : widget.stay;

      OnStay? result;
      if (editingStay != null) {
        // Update existing stay
        result = await OnStayService.update(editingStay.id, data);
      } else {
        // Create new stay
        result = await OnStayService.create(data);
      }

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(editingStay != null
                  ? 'Stay updated successfully!'
                  : 'Stay created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception('Failed to save stay');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving stay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _buildNotesString() {
    List<String> notesParts = [];

    if (_agencyNameController.text.trim().isNotEmpty) {
      notesParts.add('Agency: ${_agencyNameController.text.trim()}');
    }

    if (_agencyAddressController.text.trim().isNotEmpty) {
      notesParts.add('Agency Address: ${_agencyAddressController.text.trim()}');
    }

    if (_selectedAgentId != null) {
      notesParts.add('Agent ID: $_selectedAgentId');
    }

    if (_contractController.text.trim().isNotEmpty) {
      notesParts.add('Contract: ${_contractController.text.trim()}');
    }

    if (_flightCostController.text.trim().isNotEmpty) {
      notesParts.add('Flight Cost: ${_flightCostController.text.trim()}');
    }

    if (_hasPocketMoney && _pocketMoneyCostController.text.trim().isNotEmpty) {
      notesParts.add('Pocket Money: ${_pocketMoneyCostController.text.trim()}');
    }

    if (_notesController.text.trim().isNotEmpty) {
      notesParts.add('Additional Notes: ${_notesController.text.trim()}');
    }

    return notesParts.join('\n\n');
  }
}
