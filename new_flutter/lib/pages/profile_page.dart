import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _fromOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _loadUserData();
  }

  void _checkOnboardingStatus() {
    // Check if this page was accessed from onboarding
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('from_onboarding')) {
      setState(() {
        _fromOnboarding = uri.queryParameters['from_onboarding'] == 'true';
        _isEditing = _fromOnboarding; // Start in edit mode if from onboarding
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _fullNameController.text = user.displayName ?? '';

      // Load additional user data from Firestore
      try {
        final userData = await authService.getUserData();
        if (userData != null) {
          _bioController.text = userData['bio'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _websiteController.text = userData['website'] ?? '';
          _instagramController.text = userData['instagram'] ?? '';
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();

      // Update user profile data
      await authService.updateUserData({
        'full_name': _fullNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'website': _websiteController.text.trim(),
        'instagram': _instagramController.text.trim(),
      });

      // If coming from onboarding, mark onboarding as completed
      if (_fromOnboarding) {
        await authService.updateOnboardingCompleted(true);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isEditing = false; // Exit edit mode
            _fromOnboarding = false; // No longer from onboarding
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile setup completed! Welcome to ModelLog.'),
              backgroundColor: AppTheme.goldColor,
            ),
          );

          // Stay on profile page - don't navigate away
        }
      } else {
        if (mounted) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.goldColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return AppLayout(
      currentPage: '/profile',
      title: _fromOnboarding ? 'Setup Your Profile' : 'Profile',
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.goldColor),
            onPressed: () => setState(() => _isEditing = true),
          )
        else ...[
          TextButton(
            onPressed: _isLoading ? null : () {
              setState(() => _isEditing = false);
              _loadUserData(); // Reset form
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.goldColor,
                    ),
                  )
                : Text(
                    _fromOnboarding ? 'Complete Setup' : 'Save',
                    style: const TextStyle(color: AppTheme.goldColor),
                  ),
          ),
        ],
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Onboarding Welcome Message
              if (_fromOnboarding) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.celebration,
                        color: AppTheme.goldColor,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Welcome to ModelLog!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your profile setup to get started with managing your modeling career.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),
              ],

              // Profile Picture Section
              _buildProfilePictureSection(user).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Personal Information
              _buildSectionCard(
                title: 'Personal Information',
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Full name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    enabled: false, // Email usually can't be changed
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on,
                    enabled: _isEditing,
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Professional Information
              _buildSectionCard(
                title: 'Professional Information',
                children: [
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    icon: Icons.description,
                    enabled: _isEditing,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Website',
                    icon: Icons.language,
                    enabled: _isEditing,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _instagramController,
                    label: 'Instagram',
                    icon: Icons.camera_alt,
                    enabled: _isEditing,
                    prefixText: '@',
                  ),
                ],
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Account Actions
              if (!_isEditing) ...[
                _buildSectionCard(
                  title: 'Account',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      onTap: () => _showSignOutDialog(),
                    ),
                  ],
                ).animate(delay: 600.ms).fadeIn(duration: 600.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfilePictureSection(user) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.goldColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 57,
            backgroundColor: Colors.grey[800],
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[400],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? user?.email ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (user?.email != null) ...[
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
        if (_isEditing) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Handle profile picture change
            },
            icon: const Icon(Icons.camera_alt, color: AppTheme.goldColor),
            label: const Text('Change Photo', style: TextStyle(color: AppTheme.goldColor)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.goldColor),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey[500],
      ),
      // Add cursor styling for better visibility
      cursorColor: const Color(0xFFD4AF37), // Gold color
      cursorWidth: 2.0,
      showCursor: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? AppTheme.goldColor : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? AppTheme.goldColor : Colors.grey[600],
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: enabled ? Colors.white : Colors.grey[500],
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[800] : Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.goldColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
