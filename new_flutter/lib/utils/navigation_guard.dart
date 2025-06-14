import 'package:flutter/material.dart';

/// Navigation guard to prevent unwanted redirects and loops
class NavigationGuard {
  static final NavigationGuard _instance = NavigationGuard._internal();
  factory NavigationGuard() => _instance;
  NavigationGuard._internal();

  // Track recent navigation attempts to prevent loops
  final Map<String, DateTime> _recentNavigations = {};
  final Duration _cooldownDuration = const Duration(milliseconds: 500);

  /// Check if navigation to a route is allowed (prevents rapid redirects)
  bool canNavigateTo(String route) {
    final now = DateTime.now();
    final lastNavigation = _recentNavigations[route];
    
    if (lastNavigation != null) {
      final timeDiff = now.difference(lastNavigation);
      if (timeDiff < _cooldownDuration) {
        debugPrint('Navigation to $route blocked - too recent (${timeDiff.inMilliseconds}ms ago)');
        return false;
      }
    }
    
    return true;
  }

  /// Record a navigation attempt
  void recordNavigation(String route) {
    _recentNavigations[route] = DateTime.now();
    
    // Clean up old entries (older than 5 seconds)
    final cutoff = DateTime.now().subtract(const Duration(seconds: 5));
    _recentNavigations.removeWhere((key, value) => value.isBefore(cutoff));
  }

  /// Safe navigation that prevents loops
  static Future<void> navigateTo(BuildContext context, String route, {bool replace = false}) async {
    final guard = NavigationGuard();
    
    if (!guard.canNavigateTo(route)) {
      return;
    }

    guard.recordNavigation(route);
    
    if (replace) {
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  /// Safe replacement navigation
  static Future<void> replaceTo(BuildContext context, String route) async {
    return navigateTo(context, route, replace: true);
  }

  /// Clear navigation history (useful for logout)
  void clearHistory() {
    _recentNavigations.clear();
  }
}
