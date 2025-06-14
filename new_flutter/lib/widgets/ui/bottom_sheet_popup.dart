import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_flutter/theme/app_theme.dart';

class BottomSheetPopup extends StatelessWidget {
  final String title;
  final List<PopupMenuItem> items;
  final VoidCallback? onClose;

  const BottomSheetPopup({
    super.key,
    required this.title,
    required this.items,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<PopupMenuItem> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetPopup(
        title: title,
        items: items,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[800],
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),

          // Menu Items
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMenuItem(context, item, index);
              },
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ).animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildMenuItem(BuildContext context, PopupMenuItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: item.icon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item.iconColor ?? AppTheme.goldColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor ?? AppTheme.goldColor,
                  size: 20,
                ),
              )
            : null,
        title: Text(
          item.title,
          style: TextStyle(
            color: item.isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
                item.subtitle!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              )
            : null,
        trailing: item.trailing ??
            (item.onTap != null
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[500],
                    size: 16,
                  )
                : null),
        onTap: () {
          if (item.onTap != null) {
            Navigator.pop(context);
            item.onTap!();
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.grey[800],
        splashColor: (item.iconColor ?? AppTheme.goldColor).withValues(alpha: 0.1),
      ),
    ).animate(delay: Duration(milliseconds: 150 + (index * 50)))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }
}

class PopupMenuItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const PopupMenuItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });
}

// Profile popup specifically
class ProfilePopup extends StatelessWidget {
  final String userEmail;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  const ProfilePopup({
    super.key,
    required this.userEmail,
    this.onProfileTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  static Future<void> show({
    required BuildContext context,
    required String userEmail,
    VoidCallback? onProfileTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onLogoutTap,
  }) {
    return BottomSheetPopup.show(
      context: context,
      title: userEmail,
      items: [
        PopupMenuItem(
          title: 'Profile',
          subtitle: 'Manage your profile information',
          icon: Icons.person_outline,
          onTap: onProfileTap,
        ),
        PopupMenuItem(
          title: 'Settings',
          subtitle: 'App preferences and configuration',
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
        PopupMenuItem(
          title: 'Logout',
          subtitle: 'Sign out of your account',
          icon: Icons.logout,
          iconColor: Colors.red,
          isDestructive: true,
          onTap: onLogoutTap,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetPopup(
      title: userEmail,
      items: [
        PopupMenuItem(
          title: 'Profile',
          subtitle: 'Manage your profile information',
          icon: Icons.person_outline,
          onTap: onProfileTap,
        ),
        PopupMenuItem(
          title: 'Settings',
          subtitle: 'App preferences and configuration',
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
        PopupMenuItem(
          title: 'Logout',
          subtitle: 'Sign out of your account',
          icon: Icons.logout,
          iconColor: Colors.red,
          isDestructive: true,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
