import 'package:logger/logger.dart';

/// Logger service for the application
/// Replaces print statements with proper logging
class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  /// Log debug information
  static void debug(String message) {
    _logger.d(message);
  }

  /// Log general information
  static void info(String message) {
    _logger.i(message);
  }

  /// Log warnings
  static void warning(String message) {
    _logger.w(message);
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log verbose information (only in debug mode)
  static void verbose(String message) {
    _logger.t(message);
  }
}
