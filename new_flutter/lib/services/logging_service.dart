import 'package:flutter/foundation.dart';

/// A centralized logging service for the application
class LoggingService {
  static const String _tag = 'ModelDay';

  /// Log an error message
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ERROR: $message');
      if (error != null) {
        debugPrint('[$_tag] Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag] Stack trace: $stackTrace');
      }
    }
  }

  /// Log a warning message
  static void logWarning(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] WARNING: $message');
    }
  }

  /// Log an info message
  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] INFO: $message');
    }
  }

  /// Log a debug message (only in debug mode)
  static void logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] DEBUG: $message');
    }
  }

  /// Log API related messages
  static void logApi(String endpoint, String method, [String? message]) {
    if (kDebugMode) {
      debugPrint('[$_tag] API: $method $endpoint${message != null ? ' - $message' : ''}');
    }
  }

  /// Log navigation events
  static void logNavigation(String route, [String? message]) {
    if (kDebugMode) {
      debugPrint('[$_tag] NAVIGATION: $route${message != null ? ' - $message' : ''}');
    }
  }
}
