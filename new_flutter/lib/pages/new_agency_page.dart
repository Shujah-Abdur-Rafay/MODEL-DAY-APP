import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';

import 'package:new_flutter/services/agencies_service.dart';

class NewAgencyPage extends StatefulWidget {
  const NewAgencyPage({super.key});

  @override
  State<NewAgencyPage> createState() => _NewAgencyPageState();
}

class _NewAgencyPageState extends State<NewAgencyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _notesController = TextEditingController();

  // Contract fields
  final _contractSignedController = TextEditingController();
  final _contractExpiredController = TextEditingController();

  // Main Booker
  final _mainBookerNameController = TextEditingController();
  final _mainBookerEmailController = TextEditingController();
  final _mainBookerPhoneController = TextEditingController();

  // Finance Contact
  final _financeNameController = TextEditingController();
  final _financeEmailController = TextEditingController();
  final _financePhoneController = TextEditingController();

  String _selectedStatus = 'active';
  String _selectedType = 'representing';
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingId;
  DateTime? _contractSigned;
  DateTime? _contractExpired;

  final List<String> _statusOptions = ['active', 'inactive', 'pending'];
  final List<String> _typeOptions = ['representing', 'mother agency'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _loadAgency(args);
      }
    });
  }

  Future<void> _loadAgency(String id) async {
    setState(() {
      _isLoading = true;
      _isEditing = true;
      _editingId = id;
    });

    try {
      final agency = await AgenciesService.getById(id);
      if (agency != null) {
        setState(() {
          _nameController.text = agency.name;
          _selectedType = agency.agencyType ?? 'representing';
          _websiteController.text = agency.website ?? '';
          _addressController.text = agency.address ?? '';
          _cityController.text = agency.city ?? '';
          _countryController.text = agency.country ?? '';
          _commissionRateController.text = agency.commissionRate.toString();
          _notesController.text = agency.notes ?? '';
          _selectedStatus = agency.status ?? 'active';

          // Contract dates
          if (agency.contractSigned != null) {
            _contractSigned = agency.contractSigned;
            _contractSignedController.text =
                '${agency.contractSigned!.day}/${agency.contractSigned!.month}/${agency.contractSigned!.year}';
          }
          if (agency.contractExpired != null) {
            _contractExpired = agency.contractExpired;
            _contractExpiredController.text =
                '${agency.contractExpired!.day}/${agency.contractExpired!.month}/${agency.contractExpired!.year}';
          }

          // Main Booker
          if (agency.mainBooker != null) {
            _mainBookerNameController.text = agency.mainBooker!.name;
            _mainBookerEmailController.text = agency.mainBooker!.email;
            _mainBookerPhoneController.text = agency.mainBooker!.phone;
          }

          // Finance Contact
          if (agency.financeContact != null) {
            _financeNameController.text = agency.financeContact!.name;
            _financeEmailController.text = agency.financeContact!.email;
            _financePhoneController.text = agency.financeContact!.phone;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading agency: $e'),
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
    _nameController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _commissionRateController.dispose();
    _notesController.dispose();
    _mainBookerNameController.dispose();
    _mainBookerEmailController.dispose();
    _mainBookerPhoneController.dispose();
    _financeNameController.dispose();
    _financeEmailController.dispose();
    _financePhoneController.dispose();
    _contractSignedController.dispose();
    _contractExpiredController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final agencyData = {
        'name': _nameController.text,
        'agency_type': _selectedType,
        'website':
            _websiteController.text.isEmpty ? null : _websiteController.text,
        'address':
            _addressController.text.isEmpty ? null : _addressController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'country':
            _countryController.text.isEmpty ? null : _countryController.text,
        'commission_rate':
            double.tryParse(_commissionRateController.text) ?? 0.0,
        'contract_signed': _contractSigned?.toIso8601String(),
        'contract_expired': _contractExpired?.toIso8601String(),
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'status': _selectedStatus,
        'main_booker': {
          'name': _mainBookerNameController.text,
          'email': _mainBookerEmailController.text,
          'phone': _mainBookerPhoneController.text,
        },
        'finance_contact': {
          'name': _financeNameController.text,
          'email': _financeEmailController.text,
          'phone': _financePhoneController.text,
        },
      };

      if (_isEditing && _editingId != null) {
        await AgenciesService.update(_editingId!, agencyData);
      } else {
        await AgenciesService.create(agencyData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving agency: $e'),
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
        currentPage: '/new-agency',
        title: _isEditing ? 'Edit Agency' : 'New Agency',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppLayout(
      currentPage: '/new-agency',
      title: _isEditing ? 'Edit Agency' : 'New Agency',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    label: 'Agency Name',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter agency name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTypeField(),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Website',
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Address',
                    controller: _addressController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'City',
                          controller: _cityController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Country',
                          controller: _countryController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'Commission Rate (%)',
                          controller: _commissionRateController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusField(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Booker
              _buildSectionCard(
                'Main Booker',
                [
                  ui.Input(
                    label: 'Name',
                    controller: _mainBookerNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter main booker name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    controller: _mainBookerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter main booker email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Phone',
                    controller: _mainBookerPhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Finance Contact
              _buildSectionCard(
                'Finance Contact',
                [
                  ui.Input(
                    label: 'Name',
                    controller: _financeNameController,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    controller: _financeEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Phone',
                    controller: _financePhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contract Information
              _buildSectionCard(
                'Contract Information',
                [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Contract Signed Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: _contractSignedController,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _contractSigned ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _contractSigned = date;
                                _contractSignedController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Contract Expired Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: _contractExpiredController,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _contractExpired ??
                                  DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _contractExpired = date;
                                _contractExpiredController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ),
                    ],
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
                          : (_isEditing ? 'Update Agency' : 'Create Agency'),
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
            value: _selectedStatus,
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
                _selectedStatus = value ?? 'active';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agency Type',
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
            value: _selectedType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _typeOptions.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value ?? 'representing';
              });
            },
          ),
        ),
      ],
    );
  }
}
