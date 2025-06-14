import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize connectivity monitoring
  void initialize() {
    _checkConnectivity();
    // Check connectivity every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectivity();
    });
  }

  /// Check internet connectivity
  Future<void> _checkConnectivity() async {
    try {
      final wasOnline = _isOnline;

      if (kIsWeb) {
        // For web, use navigator.onLine API through JavaScript
        _isOnline = await _checkWebConnectivity();
      } else {
        // For mobile/desktop, use InternetAddress.lookup
        final result = await InternetAddress.lookup('google.com');
        _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }

      if (wasOnline != _isOnline) {
        debugPrint('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
        _connectivityController.add(_isOnline);
      }
    } catch (e) {
      final wasOnline = _isOnline;

      if (kIsWeb) {
        // On web, if we get an error, assume we're online
        // The browser will handle actual connectivity issues
        _isOnline = true;
      } else {
        _isOnline = false;
      }

      if (wasOnline != _isOnline) {
        debugPrint('Connectivity check failed: $e');
        _connectivityController.add(_isOnline);
      }
    }
  }

  /// Check web connectivity using browser APIs
  Future<bool> _checkWebConnectivity() async {
    try {
      // For web, we'll use a simple approach - assume online unless proven otherwise
      // The browser's navigator.onLine is not reliable, so we'll default to true
      return true;
    } catch (e) {
      return true; // Default to online for web
    }
  }

  /// Force check connectivity
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Wait for connectivity to be restored
  Future<void> waitForConnectivity({Duration timeout = const Duration(minutes: 2)}) async {
    if (_isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = connectivityStream.listen((isOnline) {
      if (isOnline) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Set a timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Connectivity timeout', timeout));
      }
    });

    return completer.future;
  }

  void dispose() {
    _connectivityController.close();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}
