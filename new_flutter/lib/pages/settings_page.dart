import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = true;
  bool _biometricAuth = false;
  String _language = 'English';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/settings',
      title: 'Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Account Settings
            _buildSettingsSection(
              title: 'Account',
              icon: Icons.person,
              children: [
                _buildSettingsTile(
                  title: 'Profile',
                  subtitle: 'Manage your profile information',
                  icon: Icons.person_outline,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildSettingsTile(
                  title: 'Privacy',
                  subtitle: 'Control your privacy settings',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                _buildSettingsTile(
                  title: 'Security',
                  subtitle: 'Password and security options',
                  icon: Icons.security_outlined,
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
              ],
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Notifications
            _buildSettingsSection(
              title: 'Notifications',
              icon: Icons.notifications,
              children: [
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive notifications from the app',
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                if (_notificationsEnabled) ...[
                  _buildSwitchTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) =>
                        setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    value: _pushNotifications,
                    onChanged: (value) =>
                        setState(() => _pushNotifications = value),
                  ),
                ],
              ],
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Appearance
            _buildSettingsSection(
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
                _buildDropdownTile(
                  title: 'Language',
                  subtitle: 'Choose your preferred language',
                  value: _language,
                  items: ['English', 'Spanish', 'French', 'German', 'Italian'],
                  onChanged: (value) => setState(() => _language = value!),
                ),
                _buildDropdownTile(
                  title: 'Currency',
                  subtitle: 'Default currency for rates',
                  value: _currency,
                  items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
                  onChanged: (value) => setState(() => _currency = value!),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Security
            _buildSettingsSection(
              title: 'Security',
              icon: Icons.security,
              children: [
                _buildSwitchTile(
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID',
                  value: _biometricAuth,
                  onChanged: (value) => setState(() => _biometricAuth = value),
                ),
                _buildSettingsTile(
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  icon: Icons.lock_outline,
                  onTap: () {
                    // Navigate to change password
                  },
                ),
                _buildSettingsTile(
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  icon: Icons.verified_user_outlined,
                  onTap: () {
                    // Navigate to 2FA settings
                  },
                ),
              ],
            ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Data & Storage
            _buildSettingsSection(
              title: 'Data & Storage',
              icon: Icons.storage,
              children: [
                _buildSettingsTile(
                  title: 'Export Data',
                  subtitle: 'Download your data',
                  icon: Icons.download_outlined,
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                _buildSettingsTile(
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  icon: Icons.cleaning_services_outlined,
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
                _buildSettingsTile(
                  title: 'Backup & Sync',
                  subtitle: 'Manage your data backup',
                  icon: Icons.backup_outlined,
                  onTap: () {
                    // Navigate to backup settings
                  },
                ),
              ],
            ).animate(delay: 800.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // About
            _buildSettingsSection(
              title: 'About',
              icon: Icons.info,
              children: [
                _buildSettingsTile(
                  title: 'App Version',
                  subtitle: '1.0.0',
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
                _buildSettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  icon: Icons.description_outlined,
                  onTap: () {
                    // Navigate to terms
                  },
                ),
                _buildSettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                _buildSettingsTile(
                  title: 'Contact Support',
                  subtitle: 'Get help and support',
                  icon: Icons.support_outlined,
                  onTap: () {
                    // Navigate to support
                  },
                ),
              ],
            ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.goldColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.goldColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.goldColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[500],
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.goldColor,
        activeTrackColor: AppTheme.goldColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: DropdownButton<String>(
        value: items.contains(value) ? value : items.first,
        onChanged: onChanged,
        dropdownColor: Colors.grey[800],
        style: const TextStyle(color: Colors.white),
        underline: Container(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Export Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will export all your data to a downloadable file. Continue?',
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
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export started...'),
                  backgroundColor: AppTheme.goldColor,
                ),
              );
            },
            child: const Text('Export',
                style: TextStyle(color: AppTheme.goldColor)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear Cache',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will clear all cached data and free up storage space. Continue?',
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
              // Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.goldColor,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
