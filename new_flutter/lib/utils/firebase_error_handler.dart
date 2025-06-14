import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  /// Get user-friendly error message from Firebase exception
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        // Firestore errors
        case 'unavailable':
          return 'Service temporarily unavailable. Please check your internet connection and try again.';
        case 'deadline-exceeded':
          return 'Request timed out. Please try again.';
        case 'permission-denied':
          return 'You don\'t have permission to perform this action.';
        case 'not-found':
          return 'The requested data was not found.';
        case 'already-exists':
          return 'This data already exists.';
        case 'resource-exhausted':
          return 'Service is temporarily overloaded. Please try again later.';
        case 'failed-precondition':
          return 'Operation failed due to invalid conditions.';
        case 'aborted':
          return 'Operation was aborted. Please try again.';
        case 'out-of-range':
          return 'Invalid data range provided.';
        case 'unimplemented':
          return 'This feature is not yet implemented.';
        case 'internal':
          return 'Internal server error. Please try again later.';
        case 'data-loss':
          return 'Data corruption detected. Please contact support.';
        case 'unauthenticated':
          return 'Please sign in to continue.';
        
        // Auth errors
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'invalid-credential':
          return 'Invalid credentials provided.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'requires-recent-login':
          return 'Please sign in again to complete this action.';
        
        default:
          return error.message ?? 'An unexpected error occurred. Please try again.';
      }
    }
    
    // Network errors
    if (error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('timeout')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Show error dialog with retry option
  static Future<bool?> showErrorDialog({
    required BuildContext context,
    required String title,
    required dynamic error,
    bool showRetry = true,
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          getErrorMessage(error),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          if (showRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onRetry?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar({
    required BuildContext context,
    required dynamic error,
    VoidCallback? onRetry,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'resource-exhausted':
        case 'internal':
        case 'aborted':
        case 'unknown':
          return true;
        default:
          return false;
      }
    }
    
    // Network errors are generally retryable
    if (error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('timeout')) {
      return true;
    }
    
    return false;
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
          return Icons.wifi_off;
        case 'permission-denied':
        case 'unauthenticated':
          return Icons.lock;
        case 'not-found':
          return Icons.search_off;
        case 'already-exists':
          return Icons.warning;
        default:
          return Icons.error;
      }
    }
    
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return Icons.wifi_off;
    }
    
    return Icons.error;
  }

  /// Get error color based on severity
  static Color getErrorColor(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
          return Colors.orange;
        case 'permission-denied':
        case 'unauthenticated':
          return Colors.red;
        case 'not-found':
          return Colors.blue;
        case 'already-exists':
          return Colors.amber;
        default:
          return Colors.red;
      }
    }
    
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return Colors.orange;
    }
    
    return Colors.red;
  }
}
