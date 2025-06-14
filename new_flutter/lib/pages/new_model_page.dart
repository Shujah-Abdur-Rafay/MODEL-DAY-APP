import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';

class NewModelPage extends StatefulWidget {
  const NewModelPage({super.key});

  @override
  State<NewModelPage> createState() => _NewModelPageState();
}

class _NewModelPageState extends State<NewModelPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bustController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _shoeSizeController = TextEditingController();
  final _hairColorController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _agencyController = TextEditingController();
  final _instagramController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = '';
  String _selectedEthnicity = '';
  bool _isLoading = false;

  final List<String> _genderOptions = ['Female', 'Male', 'Non-binary', 'Other'];

  final List<String> _ethnicityOptions = [
    'Asian',
    'Black/African',
    'Caucasian',
    'Hispanic/Latino',
    'Middle Eastern',
    'Mixed',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bustController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoeSizeController.dispose();
    _hairColorController.dispose();
    _eyeColorController.dispose();
    _agencyController.dispose();
    _instagramController.dispose();
    _portfolioController.dispose();
    _experienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create model data
      final modelData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'ethnicity': _selectedEthnicity,
        'height': _heightController.text,
        'weight': _weightController.text,
        'bust': _bustController.text,
        'waist': _waistController.text,
        'hips': _hipsController.text,
        'shoe_size': _shoeSizeController.text,
        'hair_color': _hairColorController.text,
        'eye_color': _eyeColorController.text,
        'agency': _agencyController.text,
        'instagram': _instagramController.text,
        'portfolio': _portfolioController.text,
        'experience': _experienceController.text,
        'notes': _notesController.text,
        'created_date': DateTime.now().toIso8601String(),
      };

      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Model created: $modelData');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating model profile: $e'),
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
    return AppLayout(
      currentPage: '/new-model',
      title: 'New Model Profile',
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
                    label: 'Full Name',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter model name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildGenderField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildEthnicityField()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Physical Measurements
              _buildSectionCard(
                'Physical Measurements',
                [
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'Height (cm)',
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Weight (kg)',
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'Bust (cm)',
                          controller: _bustController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Waist (cm)',
                          controller: _waistController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Hips (cm)',
                          controller: _hipsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'Shoe Size',
                          controller: _shoeSizeController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Hair Color',
                          controller: _hairColorController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Eye Color',
                          controller: _eyeColorController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Professional Information
              _buildSectionCard(
                'Professional Information',
                [
                  ui.Input(
                    label: 'Agency',
                    controller: _agencyController,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Instagram Username (without @)',
                    controller: _instagramController,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Portfolio Website',
                    controller: _portfolioController,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Experience',
                    controller: _experienceController,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              _buildSectionCard(
                'Notes',
                [
                  ui.Input(
                    label: 'Additional Notes',
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
                      text: _isLoading ? 'Creating...' : 'Create Model Profile',
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

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
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
            value: _selectedGender.isNotEmpty && _genderOptions.contains(_selectedGender)
                ? _selectedGender
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            hint: const Text(
              'Select gender',
              style: TextStyle(color: Colors.white70),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(
                  gender,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEthnicityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ethnicity',
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
            value: _selectedEthnicity.isNotEmpty && _ethnicityOptions.contains(_selectedEthnicity) ? _selectedEthnicity : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            hint: const Text(
              'Select ethnicity',
              style: TextStyle(color: Colors.white70),
            ),
            items: _ethnicityOptions.map((ethnicity) {
              return DropdownMenuItem<String>(
                value: ethnicity,
                child: Text(
                  ethnicity,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEthnicity = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }
}
