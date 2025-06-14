import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_guard.dart';

class WelcomeGuide extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const WelcomeGuide({
    super.key,
    required this.isOpen,
    required this.onClose,
  });

  @override
  State<WelcomeGuide> createState() => _WelcomeGuideState();
}

class _WelcomeGuideState extends State<WelcomeGuide>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _completed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TourStep> _steps = [
    const TourStep(
      title: "Welcome to ModelLog! ✨",
      description:
          "Let's get you started with managing your modeling career. Here's a quick tour of what you can do.",
      icon: null,
      gradient: LinearGradient(
        colors: [Color(0xFFCDAA7D), Color(0xFFB8976C)],
      ),
    ),
    const TourStep(
      title: "Add a Profile Picture",
      description:
          "Personalize your ModelLog experience by adding a profile picture. You can always update it later from your profile settings.",
      icon: Icons.account_circle,
      gradient: LinearGradient(
        colors: [Colors.green, Colors.teal],
      ),
      action: '/profile?from_onboarding=true',
    ),
    const TourStep(
      title: "Track Your Jobs",
      description:
          "Log all your modeling jobs, from fashion shows to commercial shoots. Keep track of rates, dates, client details, and earnings in one place.",
      icon: Icons.work,
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.indigo],
      ),
      action: '/jobs',
    ),
    const TourStep(
      title: "Record Castings",
      description:
          "Keep track of all your castings, callbacks, and their outcomes. Turn successful castings into jobs with one click and never miss an opportunity.",
      icon: Icons.videocam,
      gradient: LinearGradient(
        colors: [Colors.indigo, Colors.purple],
      ),
      action: '/castings',
    ),
    const TourStep(
      title: "Photo Shoots & Tests",
      description:
          "Manage your test shoots, polaroids, and professional photo sessions. Store all the important details and build your portfolio.",
      icon: Icons.camera_alt,
      gradient: LinearGradient(
        colors: [Colors.pink, Colors.red],
      ),
      action: '/shootings',
    ),
    const TourStep(
      title: "Network & Contacts",
      description:
          "Build your professional network. Keep track of agencies, agents, and industry contacts all in one place. Grow your modeling career connections.",
      icon: Icons.people,
      gradient: LinearGradient(
        colors: [Colors.orange, Colors.deepOrange],
      ),
      action: '/agents',
    ),
    const TourStep(
      title: "AI-Powered Features",
      description:
          "Use our AI assistant to help you find jobs, prepare for castings, get career advice, and optimize your modeling portfolio with personalized recommendations.",
      icon: Icons.auto_awesome,
      gradient: LinearGradient(
        colors: [Colors.purple, Colors.deepPurple],
      ),
      action: '/ai-chat',
    ),
    const TourStep(
      title: "Customize Your Experience",
      description:
          "Personalize your ModelLog experience in settings. Add the app to your home screen for quick access and configure your preferences.",
      icon: Icons.settings,
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.blueAccent],
      ),
      action: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _animationController.forward();
      _markTourAsSeen();
    }
  }

  @override
  void didUpdateWidget(WelcomeGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _animationController.forward();
      _markTourAsSeen();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _markTourAsSeen() async {
    try {
      final authService = AuthService();
      await authService.markOnboardingTourAsSeen();
      debugPrint('Tour marked as seen');
    } catch (e) {
      debugPrint('Error marking tour as seen: $e');
    }
  }

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleComplete();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleComplete() async {
    try {
      setState(() {
        _completed = true;
      });

      // Mark onboarding as completed in the database
      final authService = AuthService();
      await authService.updateOnboardingCompleted(true);
      debugPrint('Onboarding marked as completed');

      await Future.delayed(const Duration(milliseconds: 1500));
      widget.onClose();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      widget.onClose();
    }
  }

  void _handleTryNow() {
    final step = _steps[_currentStep];
    if (step.action != null) {
      // Close the tour first
      widget.onClose();

      // Navigate to the page with a slight delay to ensure smooth transition
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          NavigationGuard.navigateTo(context, step.action!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _completed ? "Welcome to ModelLog! ✨" : _steps[_currentStep].title,
                          style: const TextStyle(
                            color: AppTheme.goldColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildContent(),
                ),

                // Progress indicators
                if (!_completed) ...[
                  const SizedBox(height: 24),
                  _buildProgressIndicators(),
                ],

                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildFooter(),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_completed) {
      return Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.goldColor, Color(0xFFB8976C)],
              ),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.black,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all set! Welcome to ModelLog.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final step = _steps[_currentStep];
    return Column(
      children: [
        if (step.icon != null) ...[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: step.gradient,
            ),
            child: Icon(
              step.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          step.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (_currentStep == 1) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Close the tour first
              widget.onClose();

              // Navigate to profile setup with a slight delay
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  NavigationGuard.navigateTo(context, '/profile?from_onboarding=true');
                }
              });
            },
            icon: const Icon(Icons.account_circle),
            label: const Text('Setup Your Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep
                ? AppTheme.goldColor
                : Colors.white24,
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    if (_completed) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: _handleBack,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E2E2E)),
              foregroundColor: Colors.white70,
            ),
            child: const Text('Back'),
          ),
        const Spacer(),
        if (_steps[_currentStep].action != null && _currentStep > 1)
          OutlinedButton(
            onPressed: _handleTryNow,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.goldColor),
              foregroundColor: AppTheme.goldColor,
            ),
            child: const Text('Try Now'),
          ),
        if (_steps[_currentStep].action != null && _currentStep > 1)
          const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldColor,
            foregroundColor: Colors.black,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_currentStep == _steps.length - 1 ? 'Get Started' : 'Next'),
              if (_currentStep < _steps.length - 1) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData? icon;
  final LinearGradient gradient;
  final String? action;

  const TourStep({
    required this.title,
    required this.description,
    this.icon,
    required this.gradient,
    this.action,
  });
}
