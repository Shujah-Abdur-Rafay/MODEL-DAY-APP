import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/logger_service.dart';
import 'package:new_flutter/widgets/ui/button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();

  bool _isNavBarVisible = true;
  double _lastScrollOffset = 0;
  bool _hasRedirected = false;

  void _scrollToFeatures() {
    final context = _featuresKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 LandingPage.initState() called');
    _scrollController.addListener(_onScroll);
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Check auth status once and redirect if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasRedirected) return;

      final authService = context.read<AuthService>();
      debugPrint(
          '🔍 LandingPage - Auth user: ${authService.currentUser?.email ?? 'null'}');

      if (authService.currentUser != null) {
        debugPrint(
            '🔄 LandingPage - User logged in, redirecting to welcome...');
        _hasRedirected = true;
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }



  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final isScrollingDown = currentScrollOffset > _lastScrollOffset;
    final isScrollingUp = currentScrollOffset < _lastScrollOffset;

    // Show navbar when at top or scrolling up, hide when scrolling down
    if (currentScrollOffset <= 100) {
      // Always show when near top
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
    } else if (isScrollingDown && _isNavBarVisible) {
      // Hide when scrolling down
      setState(() {
        _isNavBarVisible = false;
      });
    } else if (isScrollingUp && !_isNavBarVisible) {
      // Show when scrolling up
      setState(() {
        _isNavBarVisible = true;
      });
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ LandingPage.build() called');

    // Don't watch auth service to avoid rebuilds - auth redirect is handled in initState
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed navbar - no overlap
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width <= 360 ? 50 : 70,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width <= 360
                    ? 8
                    : MediaQuery.of(context).size.width < 768
                        ? 12
                        : 24,
                vertical: MediaQuery.of(context).size.width <= 360 ? 8 : 16,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Better responsive breakpoints
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isMobile = screenWidth <= 768;
                  final isSmallMobile = screenWidth <= 480;
                  final isVerySmall = screenWidth < 400; // Changed from <= 360 to < 400

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Flexible(
                        flex: isMobile ? 2 : 3,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: isVerySmall
                                  ? 20
                                  : isMobile
                                      ? 28
                                      : 32,
                              width: isVerySmall
                                  ? 20
                                  : isMobile
                                      ? 28
                                      : 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isVerySmall
                                    ? 10
                                    : isMobile
                                        ? 14
                                        : 16),
                                border: Border.all(
                                  color:
                                      AppTheme.goldColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(isMobile ? 14 : 16),
                                child: Image.asset(
                                  'assets/images/model_day_logo.png',
                                  width: isMobile ? 28 : 32,
                                  height: isMobile ? 28 : 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to text logo if asset fails to load
                                    return Container(
                                      width: isMobile ? 28 : 32,
                                      height: isMobile ? 28 : 32,
                                      decoration: BoxDecoration(
                                        color: AppTheme.goldColor,
                                        borderRadius: BorderRadius.circular(
                                            isMobile ? 14 : 16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'M',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (!isVerySmall) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Model Day',
                                  style: TextStyle(
                                    color: AppTheme.goldColor,
                                    fontSize: isSmallMobile
                                        ? 14
                                        : isMobile
                                            ? 16
                                            : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Auth buttons
                      Expanded(
                        flex: isMobile ? 3 : 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isVerySmall) ...[
                              // Very small screens: Compact Sign Up button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    LoggerService.info(
                                        '🔥 Sign Up button clicked!');
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 50,
                                      minHeight: 28,
                                      maxHeight: 32,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Very small screens: Compact Sign In button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    LoggerService.info(
                                        '🔥 Sign In button clicked!');
                                    Navigator.pushNamed(context, '/signin');
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 50,
                                      minHeight: 28,
                                      maxHeight: 32,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.goldColor, width: 1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: AppTheme.goldColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Normal layout for larger screens
                              // Sign Up Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    LoggerService.info(
                                        '🔥 Sign Up button clicked!');
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minWidth: isSmallMobile ? 70 : 80,
                                      minHeight: 44,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallMobile ? 14 : 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (!isMobile) ...[
                                          const Icon(Icons.person_add,
                                              size: 14, color: Colors.black),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isSmallMobile ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isSmallMobile ? 4 : 6),
                              // Sign In Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    LoggerService.info(
                                        '🔥 Sign In button clicked!');
                                    Navigator.pushNamed(context, '/signin');
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minWidth: isSmallMobile ? 70 : 80,
                                      minHeight: 44,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallMobile ? 14 : 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppTheme.goldColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (!isMobile) ...[
                                          const Icon(Icons.login,
                                              size: 14,
                                              color: AppTheme.goldColor),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: AppTheme.goldColor,
                                            fontSize: isSmallMobile ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Main content - Expanded to fill remaining space
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black,
                      Colors.grey[900]!.withValues(alpha: 0.8)
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(context).size.width < 768 ? 16 : 32,
                      ),
                      child: Column(
                        children: [
                          // Hero section
                          Container(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width <= 768
                                  ? 100
                                  : 120,
                              bottom: 40,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth <= 768;

                                // All layouts: Image positioned higher with text closer
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Add some top spacing to position image higher
                                    const SizedBox(height: 20),
                                    // Hero image - centered and positioned higher
                                    Center(
                                      child: _buildHeroImage(),
                                    ),
                                    const SizedBox(
                                        height:
                                            24), // More gap below hero image
                                    // Text content - centered and closer
                                    _buildHeroTextContent(isMobile),
                                    // Add bottom spacing to match top spacing
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                          ),

                          // Features section
                          Container(
                            key: _featuresKey,
                            padding: const EdgeInsets.only(top: 60, bottom: 80),
                            child: Column(
                              children: [
                                Text(
                                  'Everything You Need',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[100],
                                  ),
                                ).animate().fadeIn(duration: 600.ms),
                                const SizedBox(height: 16),
                                Text(
                                  'Designed specifically for models, Modal Day helps you manage every aspect of your career.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 200.ms),
                                const SizedBox(height: 64),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // More responsive breakpoints
                                    double spacing = 24;

                                    if (constraints.maxWidth < 768) {
                                      spacing = 16;
                                    }

                                    final features = [
                                      {
                                        'icon': Icons.work,
                                        'title': 'Job Tracking',
                                        'description':
                                            'Log and manage all your modeling jobs, earnings, and client details in one place.',
                                        'delay': 0,
                                      },
                                      {
                                        'icon': Icons.calendar_today,
                                        'title': 'Casting Management',
                                        'description':
                                            'Never miss a casting call with our integrated calendar and reminder system.',
                                        'delay': 100,
                                      },
                                      {
                                        'icon': Icons.star,
                                        'title': 'Portfolio Builder',
                                        'description':
                                            'Build and maintain your digital portfolio with easy file management.',
                                        'delay': 200,
                                      },
                                      {
                                        'icon': Icons.person,
                                        'title': 'Agent Directory',
                                        'description':
                                            'Keep track of all your agents and their contact information globally.',
                                        'delay': 300,
                                      },
                                      {
                                        'icon': Icons.schedule,
                                        'title': 'Schedule Tracking',
                                        'description':
                                            'Manage your busy schedule with our intuitive calendar interface.',
                                        'delay': 400,
                                      },
                                      {
                                        'icon': Icons.shield,
                                        'title': 'Secure Storage',
                                        'description':
                                            'Your data is encrypted and securely stored in the cloud, accessible anywhere.',
                                        'delay': 500,
                                      },
                                    ];

                                    return Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth,
                                      ),
                                      child: Wrap(
                                        spacing: spacing,
                                        runSpacing: spacing,
                                        alignment: WrapAlignment.center,
                                        children: features.map((feature) {
                                          double cardWidth;
                                          double minCardWidth = 280;
                                          double maxAvailableWidth =
                                              constraints.maxWidth;

                                          // Ensure we have enough space for minimum card width
                                          if (maxAvailableWidth <
                                              minCardWidth) {
                                            minCardWidth = maxAvailableWidth -
                                                32; // Account for padding
                                            if (minCardWidth < 150) {
                                              minCardWidth =
                                                  150; // Absolute minimum
                                            }
                                          }

                                          if (constraints.maxWidth < 768) {
                                            cardWidth =
                                                constraints.maxWidth - 32;
                                          } else if (constraints.maxWidth <
                                              1200) {
                                            cardWidth = (constraints.maxWidth -
                                                    spacing * 3) /
                                                2;
                                          } else {
                                            cardWidth = (constraints.maxWidth -
                                                    spacing * 4) /
                                                3;
                                            if (cardWidth > 350) {
                                              cardWidth = 350;
                                            }
                                          }

                                          // Ensure cardWidth is within valid bounds
                                          // Make sure minCardWidth is not greater than maxAvailableWidth
                                          final safeMinWidth = minCardWidth
                                              .clamp(150.0, maxAvailableWidth);
                                          cardWidth = cardWidth.clamp(
                                              safeMinWidth, maxAvailableWidth);

                                          return Container(
                                            width: cardWidth,
                                            constraints: BoxConstraints(
                                              maxWidth: cardWidth,
                                              minWidth: safeMinWidth,
                                            ),
                                            child: _buildFeatureCard(
                                              icon: feature['icon'] as IconData,
                                              title: feature['title'] as String,
                                              description:
                                                  feature['description']
                                                      as String,
                                              delay: feature['delay'] as int,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // CTA section
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Column(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width < 768
                                            ? MediaQuery.of(context).size.width
                                            : 800,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Start Your Digital Portfolio Today',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  768
                                              ? 28
                                              : 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[100],
                                        ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(duration: 600.ms),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Join thousands of models who are already managing their careers more efficiently with Model Day.',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  768
                                              ? 16
                                              : 20,
                                          color: Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(
                                          duration: 600.ms, delay: 200.ms),
                                      const SizedBox(height: 32),
                                      Button(
                                        text: 'Create Free Account',
                                        onPressed: () async {
                                          debugPrint(
                                              'Create Free Account button pressed');
                                          try {
                                            await Navigator.pushNamed(
                                                context, '/signup');
                                          } catch (e) {
                                            debugPrint('Navigation error: $e');
                                          }
                                        },
                                        suffix: const Icon(Icons.arrow_forward,
                                            size: 18),
                                        variant: ButtonVariant.primary,
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 48),
                                      ).animate().fadeIn(
                                          duration: 600.ms, delay: 400.ms),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: const BoxDecoration(
                              border: Border(
                                top:
                                    BorderSide(color: Colors.white10, width: 1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.goldColor
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/model_day_logo.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Fallback to text logo if asset fails to load
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.goldColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'M',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '© ${DateTime.now().year} Modal Day. All rights reserved.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 500,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/hero_sec.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Debug: Print error to console
            debugPrint('Hero image asset failed to load: $error');
            // Fallback to a placeholder if image fails to load
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hero Image',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 300.ms);
  }

  Widget _buildHeroTextContent(bool isMobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 600,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Digital',
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms),
          Text(
            'Modeling Portfolio',
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
                duration: 600.ms,
                delay: 200.ms,
              ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500,
            ),
            child: Text(
              'Track your modeling jobs, manage castings, and boost your career with the all-in-one platform designed for professional models.',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                color: Colors.grey[300],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(
                duration: 600.ms,
                delay: 400.ms,
              ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallMobile = MediaQuery.of(context).size.width <= 480;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    width: isMobile ? double.infinity : null,
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 300 : double.infinity,
                    ),
                    child: Button(
                      text: isSmallMobile ? 'Get Started' : 'Get Started Free',
                      onPressed: () async {
                        debugPrint('Get Started button pressed');
                        try {
                          await Navigator.pushNamed(context, '/signup');
                        } catch (e) {
                          debugPrint('Navigation error: $e');
                        }
                      },
                      suffix: const Icon(
                        Icons.arrow_forward,
                        size: 18,
                      ),
                      variant: ButtonVariant.primary,
                      height: isMobile ? 48 : 56,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 20 : 32,
                      ),
                    ).animate().fadeIn(
                          duration: 600.ms,
                          delay: 600.ms,
                        ),
                  ),
                  Container(
                    width: isMobile ? double.infinity : null,
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 300 : double.infinity,
                    ),
                    child: Button(
                      text: 'Learn More',
                      variant: ButtonVariant.outline,
                      onPressed: () {
                        debugPrint('Learn More button pressed');
                        _scrollToFeatures();
                      },
                      suffix: const Icon(
                        Icons.chevron_right,
                        size: 18,
                      ),
                      height: isMobile ? 48 : 56,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 20 : 32,
                      ),
                    ).animate().fadeIn(
                          duration: 600.ms,
                          delay: 800.ms,
                        ),
                  ),
                ],
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return _HoverCard(
      child: Container(
        height: 280, // Fixed height for consistent card sizes
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.goldColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: delay));
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;

  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
