import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/calendar_preview_widget.dart';
import 'package:new_flutter/widgets/onboarding/welcome_guide.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎉 WelcomePage.initState() called');
    _initializeWelcomePage();
  }

  Future<void> _initializeWelcomePage() async {
    debugPrint('🔄 WelcomePage._initializeWelcomePage() called');
    debugPrint('🔍 WelcomePage - onboardingChecked: $_onboardingChecked');

    // Only initialize once
    if (_onboardingChecked) {
      debugPrint('✅ WelcomePage - Already initialized, skipping');
      return;
    }

    debugPrint('🎯 WelcomePage - Checking onboarding status...');
    await _checkOnboardingStatus();
    _onboardingChecked = true;
    debugPrint('✅ WelcomePage - Onboarding check complete');
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        debugPrint('Welcome Page - User: ${user.email}');

        // Check if the user has already seen the onboarding tour
        final hasSeenTour = await authService.hasSeenOnboardingTour();
        debugPrint('Welcome Page - Has seen tour: $hasSeenTour');

        // Only show the tour if the user hasn't seen it yet
        if (!hasSeenTour) {
          debugPrint('Welcome Page - Showing tour overlay for first time');
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _showTourOverlay();
            }
          });
        } else {
          debugPrint('Welcome Page - Tour already seen, skipping');
        }
      }
    } catch (error) {
      debugPrint('Error checking onboarding status: $error');
    }
  }

  Widget _buildLogOptionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showEventTypeSelector();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'Log Option',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  void _showEventTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Event Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildEventTypeChip('Direct Bookings', Icons.book_online, '/new-direct-booking'),
                _buildEventTypeChip('Direct Options', Icons.arrow_forward, '/new-direct-option'),
                _buildEventTypeChip('Jobs', Icons.work, '/new-job'),
                _buildEventTypeChip('Castings', Icons.person_search, '/new-casting'),
                _buildEventTypeChip('Test', Icons.camera, '/new-test'),
                _buildEventTypeChip('OnStay', Icons.hotel, '/new-on-stay'),
                _buildEventTypeChip('Polaroids', Icons.photo_camera, '/new-polaroid'),
                _buildEventTypeChip('Meetings', Icons.meeting_room, '/new-meeting'),
                _buildEventTypeChip('AI Jobs', Icons.smart_toy, '/new-ai-job'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(String label, IconData icon, String route) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final result = await Navigator.pushNamed(context, route);

        // If the user successfully created an item, navigate to the appropriate list page
        if (result == true) {
          _navigateToListPage(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.goldColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToListPage(String createRoute) {
    // Map creation routes to their corresponding list pages
    String listRoute;
    switch (createRoute) {
      case '/new-casting':
        listRoute = '/castings';
        break;
      case '/new-job':
        listRoute = '/jobs';
        break;
      case '/new-direct-booking':
        listRoute = '/direct-bookings';
        break;
      case '/new-direct-option':
        listRoute = '/direct-options';
        break;
      case '/new-test':
        listRoute = '/tests';
        break;
      case '/new-on-stay':
        listRoute = '/on-stay';
        break;
      case '/new-polaroid':
        listRoute = '/polaroids';
        break;
      case '/new-meeting':
        listRoute = '/meetings';
        break;
      case '/new-ai-job':
        listRoute = '/ai-jobs';
        break;
      default:
        // For unknown routes, stay on welcome page
        return;
    }

    Navigator.pushReplacementNamed(context, listRoute);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ WelcomePage.build() called');
    final user = context.read<AuthService>().currentUser;
    debugPrint('🔍 WelcomePage - Current user: ${user?.email ?? 'null'}');

    return Stack(
      children: [
        AppLayout(
          currentPage: '/welcome',
          title: 'Welcome',
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isMobile = screenWidth <= 768;
                  final isSmallMobile = screenWidth < 360;

                  return Padding(
                    padding: EdgeInsets.all(isSmallMobile
                        ? 16.0
                        : isMobile
                            ? 20.0
                            : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Welcome Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.goldColor.withValues(alpha: 0.1),
                                Colors.transparent,
                                AppTheme.goldColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.goldColor.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome Text with Custom Typography
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Welcome${user?.displayName != null ? ", ${user!.displayName}" : ""} to ',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white70,
                                        height: 1.2,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'ModelDay',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.goldColor,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 800.ms)
                                  .slideX(begin: -0.2),

                              const SizedBox(height: 16),

                              // Subtitle
                              Text(
                                'Your personal digital diary for modeling success',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.3,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 200.ms)
                                  .slideX(begin: -0.2),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1000.ms)
                            .scale(begin: const Offset(0.95, 0.95)),

                        const SizedBox(height: 32),

                        // Log Option Button
                        _buildLogOptionButton(),

                        const SizedBox(height: 32),

                        // Calendar Preview Section
                        _buildCalendarPreviewSection(),

                        const SizedBox(height: 32),

                        // Community Board Button
                        _buildCommunityBoardButton(),

                        const SizedBox(height: 24),

                        // View Options Dropdown
                        _buildViewOptionsDropdown(),

                        const SizedBox(height: 24),

                        // ModelLog AI Button
                        _buildModelLogAIButton(),

                        const SizedBox(height: 32),

                        // Navigation Options
                        _buildNavigationOptions(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPreviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!.withValues(alpha: 0.3),
            Colors.grey[900]!.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isMobile = screenWidth <= 768;
              final isSmallMobile = screenWidth < 360;

              return Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: AppTheme.goldColor,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Your Schedule',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isSmallMobile) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/calendar'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isMobile ? 'View' : 'View Full Calendar',
                        style: TextStyle(
                          color: AppTheme.goldColor,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const CalendarPreviewWidget(isFullCalendar: true),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildCommunityBoardButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/community-board');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Community Board',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildViewOptionsDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!.withValues(alpha: 0.3),
            Colors.grey[900]!.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildViewOptionChip('Options', Icons.schedule, '/options'),
              _buildViewOptionChip('Jobs', Icons.work, '/jobs'),
              _buildViewOptionChip(
                  'Castings', Icons.person_search, '/castings'),
              _buildViewOptionChip('Tests', Icons.camera, '/tests'),
              _buildViewOptionChip('Shootings', Icons.camera_alt, '/shootings'),
              _buildViewOptionChip(
                  'Polaroids', Icons.photo_camera, '/polaroids'),
              _buildViewOptionChip('Meetings', Icons.meeting_room, '/meetings'),
              _buildViewOptionChip('AI Jobs', Icons.smart_toy, '/ai-jobs'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildViewOptionChip(String label, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[700]!.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.goldColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelLogAIButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ai-chat');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_toy, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'ModelDay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildNavigationOptions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final isSmallMobile = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Navigation',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final crossAxisCount = isSmallMobile ? 2 : 2;
            final cardWidth = (availableWidth - 16) / crossAxisCount;
            final cardHeight = isSmallMobile ? 120.0 : 140.0;
            final childAspectRatio = cardWidth / cardHeight;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: childAspectRatio,
              children: [
                _buildNavigationCard(
                    'Calendar', Icons.calendar_today, '/calendar'),
                _buildNavigationCard('Track Jobs', Icons.work, '/jobs'),
                _buildNavigationCard(
                    'Network', Icons.people, '/industry-contacts'),
                _buildNavigationCard('Agent Form', Icons.person_add, '/agents'),
              ],
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildNavigationCard(String title, IconData icon, String route) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            borderRadius: BorderRadius.circular(12),
            hoverColor: AppTheme.goldColor.withValues(alpha: 0.1),
            splashColor: AppTheme.goldColor.withValues(alpha: 0.2),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[850]!.withValues(alpha: 0.9),
                    Colors.grey[900]!.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.goldColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.goldColor,
                      size: isSmallMobile ? 20 : 24,
                    ),
                  ),
                  SizedBox(height: isSmallMobile ? 8 : 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
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
