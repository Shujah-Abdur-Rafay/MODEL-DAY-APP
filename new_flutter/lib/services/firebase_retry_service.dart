import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'connectivity_service.dart';

class FirebaseRetryService {
  static final ConnectivityService _connectivity = ConnectivityService();
  
  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);
  static const Duration maxDelay = Duration(seconds: 10);

  /// Execute a Firestore operation with retry logic
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'Firestore operation',
    bool requiresConnectivity = true,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        // Check connectivity if required (skip for web)
        if (requiresConnectivity && !kIsWeb && !_connectivity.isOnline) {
          debugPrint('$operationName: No internet connection, waiting...');
          await _connectivity.waitForConnectivity(timeout: const Duration(seconds: 30));
        }

        // Execute the operation
        final result = await operation();

        if (attempts > 0) {
          debugPrint('$operationName: Succeeded after ${attempts + 1} attempts');
        }

        return result;
      } catch (e) {
        attempts++;
        
        if (_isRetryableError(e)) {
          if (attempts < maxRetries) {
            debugPrint('$operationName: Attempt $attempts failed, retrying in ${delay.inSeconds}s: $e');
            await Future.delayed(delay);
            delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
            if (delay > maxDelay) delay = maxDelay;
            continue;
          }
        }
        
        debugPrint('$operationName: Failed after $attempts attempts: $e');
        rethrow;
      }
    }

    throw Exception('$operationName: Max retries exceeded');
  }

  /// Check if an error is retryable
  static bool _isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'resource-exhausted':
        case 'internal':
        case 'unknown':
          return true;
        case 'permission-denied':
        case 'not-found':
        case 'already-exists':
        case 'invalid-argument':
        case 'failed-precondition':
        case 'out-of-range':
        case 'unimplemented':
        case 'data-loss':
        case 'unauthenticated':
          return false;
        default:
          return true; // Retry unknown Firebase errors
      }
    }
    
    // Retry network-related errors
    if (error.toString().contains('network') ||
        error.toString().contains('timeout') ||
        error.toString().contains('connection')) {
      return true;
    }
    
    return false;
  }

  /// Create a document with retry logic
  static Future<void> createDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return executeWithRetry(
      () => FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .set(data),
      operationName: 'Create document $collection/$documentId',
    );
  }

  /// Update a document with retry logic
  static Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return executeWithRetry(
      () => FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .update(data),
      operationName: 'Update document $collection/$documentId',
    );
  }

  /// Get a document with retry logic
  static Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
    Source source = Source.serverAndCache,
  }) async {
    return executeWithRetry(
      () => FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .get(GetOptions(source: source)),
      operationName: 'Get document $collection/$documentId',
      requiresConnectivity: source != Source.cache,
    );
  }

  /// Set a document with retry logic
  static Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    SetOptions? options,
  }) async {
    return executeWithRetry(
      () => FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .set(data, options),
      operationName: 'Set document $collection/$documentId',
    );
  }

  /// Delete a document with retry logic
  static Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    return executeWithRetry(
      () => FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .delete(),
      operationName: 'Delete document $collection/$documentId',
    );
  }

  /// Get a collection with retry logic
  static Future<QuerySnapshot> getCollection({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
    Source source = Source.serverAndCache,
  }) async {
    return executeWithRetry(
      () {
        CollectionReference ref = FirebaseFirestore.instance.collection(collection);
        Query query = queryBuilder?.call(ref) ?? ref;
        return query.get(GetOptions(source: source));
      },
      operationName: 'Get collection $collection',
      requiresConnectivity: source != Source.cache,
    );
  }
}
