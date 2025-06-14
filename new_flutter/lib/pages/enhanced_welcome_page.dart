import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_layout.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedWelcomePage extends StatefulWidget {
  const EnhancedWelcomePage({super.key});

  @override
  State<EnhancedWelcomePage> createState() => _EnhancedWelcomePageState();
}

class _EnhancedWelcomePageState extends State<EnhancedWelcomePage> {
  DateTime selectedDate = DateTime.now();
  String selectedMonth = 'June 2025';

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentPage: '/welcome',
      selectedIndex: 0,
      title: 'Welcome',
      onItemSelected: (index) {
        // Handle navigation based on selected index
        switch (index) {
          case 0:
            // Already on welcome page
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/calendar');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/activities');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/event-types');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/ai');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/agencies');
            break;
          case 6:
            Navigator.pushReplacementNamed(context, '/agents');
            break;
          case 7:
            Navigator.pushReplacementNamed(context, '/contacts');
            break;
          case 8:
            Navigator.pushReplacementNamed(context, '/gallery');
            break;
          case 9:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 10:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Section
                _buildProfileSection(isSmallScreen),
                const SizedBox(height: 32),

                // Welcome Message
                _buildWelcomeMessage(isSmallScreen),
                const SizedBox(height: 32),

                // Log Option Button
                _buildLogOptionButton(isSmallScreen),
                const SizedBox(height: 32),

                // Calendar and Options Section
                if (isSmallScreen)
                  _buildMobileLayout()
                else
                  _buildDesktopLayout(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(bool isSmallScreen) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // final user = authService.currentUser; // Currently unused

        return Column(
          children: [
            // Profile Picture
            Container(
              width: isSmallScreen ? 120 : 150,
              height: isSmallScreen ? 120 : 150,
              decoration: const BoxDecoration(
                color: Color(0xFFD4B896), // Beige color from original
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'M',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 40 : 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'log',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings icon
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.goldColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 600.ms),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeMessage(bool isSmallScreen) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final userName = user?.displayName ?? 'User';

        return Column(
          children: [
            Text(
              'Welcome, $userName to',
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Modal',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldColor,
                    ),
                  ),
                  TextSpan(
                    text: 'Day',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal digital diary for modeling success',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
      },
    );
  }

  Widget _buildLogOptionButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to add new activity
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 16 : 20,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log Option',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCalendarSection(true),
        const SizedBox(height: 24),
        _buildQuickOptions(true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildCalendarSection(false),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: _buildQuickOptions(false),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: Column(
        children: [
          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  // Previous month
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'today',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Next month
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Month/Year
          Text(
            selectedMonth,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // View Full Calendar Button
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
            child: const Text(
              'View Full Calendar',
              style: TextStyle(color: AppTheme.goldColor),
            ),
          ),
          const SizedBox(height: 16),

          // Calendar Grid
          _buildCalendarGrid(isSmallScreen),
          const SizedBox(height: 20),

          // View Options
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3E3E3E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Options',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ModelDay AI Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ai');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6), // Purple color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ModalDay AI',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.auto_awesome, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Widget _buildCalendarGrid(bool isSmallScreen) {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map(
                (day) => Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days
        ...List.generate(6, (weekIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;
              final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;
              final isToday = isValidDay && dayNumber == now.day;
              final isSelected = isValidDay && dayNumber == selectedDate.day;

              return GestureDetector(
                onTap: isValidDay
                    ? () {
                        if (mounted) {
                          setState(() {
                            selectedDate =
                                DateTime(now.year, now.month, dayNumber);
                          });
                        }
                      }
                    : null,
                child: Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.goldColor
                        : isToday
                            ? AppTheme.goldColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: isValidDay
                      ? Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : isToday
                                    ? AppTheme.goldColor
                                    : Colors.white,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        )
                      : null,
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildQuickOptions(bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          _buildOptionCard(
            icon: Icons.calendar_today,
            title: 'Calendar',
            subtitle: 'View your upcoming jobs and castings',
            onTap: () => Navigator.pushNamed(context, '/calendar'),
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.work,
            title: 'Track Jobs',
            subtitle: 'Log your bookings and earnings',
            onTap: () => Navigator.pushNamed(context, '/jobs'),
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.people,
            title: 'Network',
            subtitle: 'Manage industry contacts',
            onTap: () => Navigator.pushNamed(context, '/contacts'),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3E3E3E)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.goldColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
