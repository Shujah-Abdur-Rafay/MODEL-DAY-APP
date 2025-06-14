import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/ui/bottom_sheet_popup.dart' as popup;
import 'package:new_flutter/utils/navigation_guard.dart';
import '../services/auth_service.dart';
import 'onboarding/welcome_guide.dart';
import 'enhanced_icon.dart';

class Sidebar extends StatefulWidget {
  final String currentPage;
  final VoidCallback onCloseSidebar;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDesktop;

  const Sidebar({
    super.key,
    required this.currentPage,
    required this.onCloseSidebar,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isDesktop = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with TickerProviderStateMixin {
  static bool isEventTypesOpen =
      false; // Start collapsed by default and make it static to persist
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkAnimation;

  final eventTypes = [
    {
      'label': 'Option',
      'icon': Icons.schedule,
      'path': '/options',
      'color': Colors.blue,
    },
    {
      'label': 'Job',
      'icon': Icons.work,
      'path': '/jobs',
      'color': Colors.green,
    },
    {
      'label': 'Direct Option',
      'icon': Icons.arrow_forward,
      'path': '/direct-options',
      'color': Colors.cyan,
    },
    {
      'label': 'Direct Booking',
      'icon': Icons.calendar_today,
      'path': '/direct-bookings',
      'color': Colors.teal,
    },
    {
      'label': 'Casting',
      'icon': Icons.videocam,
      'path': '/castings',
      'color': Colors.purple,
    },
    {
      'label': 'On Stay',
      'icon': Icons.home,
      'path': '/on-stay',
      'color': Colors.orange,
    },
    {
      'label': 'Test',
      'icon': Icons.camera,
      'path': '/tests',
      'color': Colors.green,
    },
    {
      'label': 'Polaroids',
      'icon': Icons.image,
      'path': '/polaroids',
      'color': Colors.pink,
    },
    {
      'label': 'Meeting',
      'icon': Icons.people,
      'path': '/meetings',
      'color': Colors.yellow,
    },
    {
      'label': 'AI Jobs',
      'icon': Icons.auto_awesome,
      'path': '/ai-jobs',
      'color': Colors.white,
    },
    {
      'label': 'Other',
      'icon': Icons.more_horiz,
      'path': '/other',
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize blink animation for tour button
    _blinkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkAnimationController,
      curve: Curves.easeInOut,
    ));

    // Set animation state based on static variable
    if (isEventTypesOpen) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }

    // Check tour status
    _checkTourStatus();
  }

  Future<void> _checkTourStatus() async {
    try {
      // Always show blinking animation since tour is always available
      if (mounted) {
        _blinkAnimationController.repeat(reverse: true);
      }
    } catch (e) {
      debugPrint('Error checking tour status: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blinkAnimationController.dispose();
    super.dispose();
  }

  void _toggleEventTypes() {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();

    setState(() {
      isEventTypesOpen = !isEventTypesOpen;
      if (isEventTypesOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 280,
          color: const Color(0xFF1A1A1A), // Use dark gray instead of pure black
          child: Column(
            children: [
              // Logo and close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(16), // Make it circular
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/model_day_logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to text logo if asset fails to load
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Model Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Show appropriate button based on platform
                    if (widget.isDesktop)
                      EnhancedIconButton(
                        icon: Icons.chevron_left,
                        onPressed: widget.onCloseSidebar,
                        color: Colors.white70,
                        size: 20,
                      )
                    else
                      EnhancedIconButton(
                        icon: Icons.close,
                        onPressed: widget.onCloseSidebar,
                        color: Colors.white70,
                        size: 20,
                      ),
                  ],
                ),
              ),

              // Navigation items
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main Features
                      _buildNavItem('Welcome', Icons.home, '/welcome'),
                      _buildNavItem(
                          'Calendar', Icons.calendar_today, '/calendar'),
                      _buildNavItemWithText(
                          'Community Board', '💬', '/community-board'),
                      _buildNavItem(
                        'Full Schedule',
                        Icons.list,
                        '/all-activities',
                      ),

                      // Event Types Section
                      _buildCollapsibleSection(),

                      // AI Features
                      _buildNavItem('Model Day AI', Icons.chat, '/ai-chat'),

                      // Network Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Network',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      _buildNavItem('Agencies', Icons.business, '/agencies'),
                      _buildNavItem('Agents', Icons.person, '/agents'),
                      _buildNavItem(
                        'Industry Contacts',
                        Icons.contacts,
                        '/industry-contacts',
                      ),

                      // Gallery Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Gallery',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      _buildNavItem(
                        'Job Gallery',
                        Icons.photo_library,
                        '/job-gallery',
                      ),

                      // For Agents Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'For Agents',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      _buildNavItemWithText(
                        'Submit Event for Model',
                        '+',
                        '/submit-event',
                      ),

                      // Settings Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Settings',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      _buildNavItem(
                          'Profile', Icons.person_outline, '/profile'),
                      _buildNavItem('Settings', Icons.settings, '/settings'),

                      // Tour Button
                      const SizedBox(height: 16),
                      _buildTourButton(),
                    ],
                  ),
                ),
              ),

              // User Profile Section at bottom
              _buildUserProfileSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isEventTypesOpen
            ? Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Header with toggle functionality
          Container(
            decoration: BoxDecoration(
              color: isEventTypesOpen
                  ? AppTheme.goldColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: EnhancedIcon(
                  Icons.event,
                  size: 20,
                  color: isEventTypesOpen ? AppTheme.goldColor : Colors.white,
                ),
              ),
              title: Text(
                'Event Types',
                style: TextStyle(
                  color: isEventTypesOpen ? AppTheme.goldColor : Colors.white70,
                  fontWeight:
                      isEventTypesOpen ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: AnimatedRotation(
                turns: isEventTypesOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: EnhancedIcon(
                    Icons.expand_more,
                    size: 20,
                    color: isEventTypesOpen ? AppTheme.goldColor : Colors.white,
                  ),
                ),
              ),
              onTap: _toggleEventTypes,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Animated collapsible content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Container(
                margin: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Column(
                  children: eventTypes
                      .map(
                        (type) => Container(
                          margin: const EdgeInsets.only(bottom: 2.0),
                          child: _buildNavItem(
                            type['label'] as String,
                            type['icon'] as IconData,
                            type['path'] as String,
                            color: type['color'] as Color,
                            isSubItem: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithText(
    String label,
    String iconText,
    String path, {
    bool isSubItem = false,
  }) {
    final isSelected = path == widget.currentPage;

    return Container(
      margin: isSubItem
          ? const EdgeInsets.only(left: 8.0, right: 4.0)
          : EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppTheme.goldColor.withValues(alpha: 0.1),
          splashColor: AppTheme.goldColor.withValues(alpha: 0.2),
          onTap: () {
            // Don't refresh if already on the same page
            if (path == widget.currentPage) return;

            final index = eventTypes.indexWhere((type) => type['path'] == path);
            if (index != -1) {
              widget.onItemSelected(index);
            }

            // Only close sidebar on mobile/tablet, not desktop
            if (!widget.isDesktop) {
              widget.onCloseSidebar();
            }

            // Navigate to the new page using navigation guard to prevent loops
            NavigationGuard.replaceTo(context, path);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? AppTheme.goldColor.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSubItem ? 12.0 : 16.0,
                vertical: 0,
              ),
              leading: SizedBox(
                width: isSubItem ? 18 : 24,
                height: isSubItem ? 18 : 24,
                child: Center(
                  child: Text(
                    iconText,
                    style: TextStyle(
                      fontSize: isSubItem ? 12 : 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.goldColor : Colors.white,
                    ),
                  ),
                ),
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.goldColor : Colors.white70,
                  fontSize: isSubItem ? 13 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    String path, {
    Color? color,
    bool isSubItem = false,
  }) {
    final isSelected = path == widget.currentPage;

    return Container(
      margin: isSubItem
          ? const EdgeInsets.only(left: 8.0, right: 4.0)
          : EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppTheme.goldColor.withValues(alpha: 0.1),
          splashColor: AppTheme.goldColor.withValues(alpha: 0.2),
          onTap: () {
            // Don't refresh if already on the same page
            if (path == widget.currentPage) return;

            final index = eventTypes.indexWhere((type) => type['path'] == path);
            if (index != -1) {
              widget.onItemSelected(index);
            }

            // Only close sidebar on mobile/tablet, not desktop
            if (!widget.isDesktop) {
              widget.onCloseSidebar();
            }

            // Navigate to the new page using navigation guard to prevent loops
            NavigationGuard.replaceTo(context, path);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? AppTheme.goldColor.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSubItem ? 12.0 : 16.0,
                vertical: 0,
              ),
              leading: SizedBox(
                width: isSubItem ? 18 : 24,
                height: isSubItem ? 18 : 24,
                child: Center(
                  child: Icon(
                    icon,
                    size: isSubItem ? 16 : 20,
                    color: isSelected ? AppTheme.goldColor : Colors.white,
                    semanticLabel: label,
                  ),
                ),
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.goldColor : Colors.white70,
                  fontSize: isSubItem ? 13 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          final userName = user?.displayName ?? 'User';
          final userEmail = user?.email ?? 'user@example.com';

          return GestureDetector(
            onTap: () {
              popup.ProfilePopup.show(
                context: context,
                userEmail: userEmail,
                onProfileTap: () {
                  if (!widget.isDesktop) widget.onCloseSidebar();
                  NavigationGuard.replaceTo(context, '/profile');
                },
                onSettingsTap: () {
                  if (!widget.isDesktop) widget.onCloseSidebar();
                  NavigationGuard.replaceTo(context, '/settings');
                },
                onLogoutTap: () async {
                  if (!widget.isDesktop) widget.onCloseSidebar();
                  await authService.signOut();
                },
              );
            },
            child: Row(
              children: [
                // Profile Picture or Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.goldColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dropdown Arrow
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: EnhancedIcon(
                    Icons.expand_less,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourButton() {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Stop blinking animation when clicked
                _blinkAnimationController.stop();

                // Show tour in full-screen overlay using Navigator
                _showTourOverlay();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _blinkAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _blinkAnimation.value,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: const EnhancedIcon(
                              Icons.help,
                              size: 20,
                              color: AppTheme.goldColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _blinkAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _blinkAnimation.value,
                            child: const Text(
                              "Take the Tour",
                              style: TextStyle(
                                color: AppTheme.goldColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _blinkAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _blinkAnimation.value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.goldColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTourOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        pageBuilder: (context, animation, secondaryAnimation) {
          return WelcomeGuide(
            isOpen: true,
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
