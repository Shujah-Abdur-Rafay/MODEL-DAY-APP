import 'package:flutter/material.dart';

class SwipeNavigation extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  
  const SwipeNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  State<SwipeNavigation> createState() => _SwipeNavigationState();
}

class _SwipeNavigationState extends State<SwipeNavigation> {
  // Define the navigation order for pages
  static const List<String> _pageOrder = [
    '/welcome',
    '/calendar',
    '/all-activities',
    '/jobs',
    '/castings',
    '/tests',
    '/polaroids',
    '/meetings',
    '/direct-bookings',
    '/direct-options',
    '/on-stay',
    '/shootings',
    '/ai-jobs',
    '/agencies',
    '/agents',
    '/industry-contacts',
    '/job-gallery',
    '/profile',
    '/settings',
  ];

  void _handleSwipe(DragEndDetails details) {
    // Only enable swipe navigation on mobile devices
    if (!_isMobile()) return;

    const double sensitivity = 100.0;
    
    if (details.primaryVelocity == null) return;

    // Swipe right (previous page)
    if (details.primaryVelocity! > sensitivity) {
      _navigateToPreviousPage();
    }
    // Swipe left (next page)
    else if (details.primaryVelocity! < -sensitivity) {
      _navigateToNextPage();
    }
  }

  bool _isMobile() {
    return MediaQuery.of(context).size.width < 768;
  }

  void _navigateToPreviousPage() {
    debugPrint('👈 SwipeNavigation._navigateToPreviousPage() called');
    if (widget.onSwipeRight != null) {
      debugPrint('🔄 SwipeNavigation - Using custom onSwipeRight callback');
      widget.onSwipeRight!();
      return;
    }

    final currentIndex = _pageOrder.indexOf(widget.currentRoute);
    debugPrint('🔍 Current route: ${widget.currentRoute}, index: $currentIndex');
    if (currentIndex > 0) {
      final previousRoute = _pageOrder[currentIndex - 1];
      debugPrint('➡️ SwipeNavigation - Navigating to previous: $previousRoute');
      Navigator.pushReplacementNamed(context, previousRoute);
    } else {
      debugPrint('❌ SwipeNavigation - No previous route available');
    }
  }

  void _navigateToNextPage() {
    debugPrint('👉 SwipeNavigation._navigateToNextPage() called');
    if (widget.onSwipeLeft != null) {
      debugPrint('🔄 SwipeNavigation - Using custom onSwipeLeft callback');
      widget.onSwipeLeft!();
      return;
    }

    final currentIndex = _pageOrder.indexOf(widget.currentRoute);
    debugPrint('🔍 Current route: ${widget.currentRoute}, index: $currentIndex');
    if (currentIndex >= 0 && currentIndex < _pageOrder.length - 1) {
      final nextRoute = _pageOrder[currentIndex + 1];
      debugPrint('➡️ SwipeNavigation - Navigating to next: $nextRoute');
      Navigator.pushReplacementNamed(context, nextRoute);
    } else {
      debugPrint('❌ SwipeNavigation - No next route available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: Stack(
        children: [
          widget.child,
          // Show swipe indicators on mobile
          if (_isMobile()) _buildSwipeIndicators(),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final currentIndex = _pageOrder.indexOf(widget.currentRoute);
    final canSwipeLeft = currentIndex >= 0 && currentIndex < _pageOrder.length - 1;
    final canSwipeRight = currentIndex > 0;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canSwipeRight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (canSwipeLeft && canSwipeRight) const SizedBox(width: 20),
          if (canSwipeLeft)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Swipe',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Extension to easily add swipe navigation to any page
extension SwipeNavigationExtension on Widget {
  Widget withSwipeNavigation(String currentRoute, {
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
  }) {
    return Builder(
      builder: (context) => SwipeNavigation(
        currentRoute: currentRoute,
        onSwipeLeft: onSwipeLeft,
        onSwipeRight: onSwipeRight,
        child: this,
      ),
    );
  }
}
