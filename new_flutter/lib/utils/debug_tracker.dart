import 'package:flutter/material.dart';

/// Debug tracker to monitor app state and navigation
class DebugTracker {
  static final DebugTracker _instance = DebugTracker._internal();
  factory DebugTracker() => _instance;
  DebugTracker._internal();

  // Track page builds
  final Map<String, int> _pageBuildCounts = {};
  final Map<String, DateTime> _lastBuildTimes = {};

  // Track navigation
  final List<String> _navigationHistory = [];
  final Map<String, int> _navigationCounts = {};

  /// Track when a page builds
  void trackPageBuild(String pageName) {
    final now = DateTime.now();
    _pageBuildCounts[pageName] = (_pageBuildCounts[pageName] ?? 0) + 1;
    _lastBuildTimes[pageName] = now;

    debugPrint('🏗️ [$pageName] Build #${_pageBuildCounts[pageName]} at ${now.toIso8601String()}');

    // Check for rapid rebuilds (potential issue)
    if (_pageBuildCounts[pageName]! > 3) {
      debugPrint('⚠️ [$pageName] WARNING: Page has built ${_pageBuildCounts[pageName]} times!');
    }
  }

  /// Track navigation events
  void trackNavigation(String from, String to) {
    final now = DateTime.now();
    _navigationHistory.add('$from -> $to at ${now.toIso8601String()}');
    _navigationCounts[to] = (_navigationCounts[to] ?? 0) + 1;

    debugPrint('🧭 Navigation: $from -> $to (visit #${_navigationCounts[to]})');

    // Keep only last 20 navigation events
    if (_navigationHistory.length > 20) {
      _navigationHistory.removeAt(0);
    }

    // Check for navigation loops
    if (_navigationCounts[to]! > 3) {
      debugPrint('🔄 [$to] WARNING: Page visited ${_navigationCounts[to]} times - possible loop!');
      debugPrint('📜 Recent navigation history:');
      for (int i = _navigationHistory.length - 1; i >= 0 && i >= _navigationHistory.length - 5; i--) {
        debugPrint('   ${_navigationHistory[i]}');
      }
    }
  }

  /// Print current debug state
  void printDebugState() {
    debugPrint('🔍 === DEBUG STATE ===');
    debugPrint('📊 Page Build Counts:');
    _pageBuildCounts.forEach((page, count) {
      debugPrint('   $page: $count builds');
    });
    
    debugPrint('🧭 Navigation Counts:');
    _navigationCounts.forEach((page, count) {
      debugPrint('   $page: $count visits');
    });

    debugPrint('📜 Recent Navigation History:');
    for (int i = _navigationHistory.length - 1; i >= 0 && i >= _navigationHistory.length - 10; i--) {
      debugPrint('   ${_navigationHistory[i]}');
    }
    debugPrint('🔍 === END DEBUG STATE ===');
  }

  /// Reset all tracking data
  void reset() {
    _pageBuildCounts.clear();
    _lastBuildTimes.clear();
    _navigationHistory.clear();
    _navigationCounts.clear();
    debugPrint('🧹 Debug tracker reset');
  }

  /// Check if a page is building too frequently
  bool isPageBuildingTooFrequently(String pageName) {
    final count = _pageBuildCounts[pageName] ?? 0;
    final lastBuild = _lastBuildTimes[pageName];
    
    if (count > 5 && lastBuild != null) {
      final timeSinceFirstBuild = DateTime.now().difference(lastBuild);
      if (timeSinceFirstBuild.inSeconds < 10) {
        return true;
      }
    }
    return false;
  }
}

/// Mixin to easily add debug tracking to StatefulWidgets
mixin DebugTrackingMixin<T extends StatefulWidget> on State<T> {
  late final String _pageName;

  @override
  void initState() {
    super.initState();
    _pageName = widget.runtimeType.toString().replaceAll('Page', '');
    debugPrint('🎬 [$_pageName] initState() called');
  }

  @override
  Widget build(BuildContext context) {
    DebugTracker().trackPageBuild(_pageName);
    return buildWithDebug(context);
  }

  /// Override this instead of build()
  Widget buildWithDebug(BuildContext context);

  @override
  void dispose() {
    debugPrint('🗑️ [$_pageName] dispose() called');
    super.dispose();
  }
}
