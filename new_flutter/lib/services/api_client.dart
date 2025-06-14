import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_service.dart';
import 'token_storage_service.dart';

class ApiClient {
  static AuthService? _authService;

  /// Initialize with auth service reference
  static void initialize(AuthService authService) {
    _authService = authService;
  }

  /// Make HTTP request to Firebase/Firestore
  static Future<dynamic> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('Firebase API Request: $method $endpoint');

      // For now, return a placeholder response
      // This will be implemented with proper Firestore operations
      return {'message': 'Firebase API placeholder - implement specific operations'};
    } catch (e) {
      debugPrint('API request error: $e');
      rethrow;
    }
  }

  /// Get access token (Firebase ID token)
  static Future<String?> getAccessToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  /// Handle authentication errors
  static Future<void> handleAuthError(dynamic error) async {
    try {
      debugPrint('Handling auth error: $error');

      // Clear stored tokens
      await TokenStorageService.clearAll();

      // Force logout through auth service
      if (_authService != null) {
        await _authService!.signOut();
      }
    } catch (e) {
      debugPrint('Error handling auth error: $e');
    }
  }

  /// Upload file to Firebase Storage
  static Future<String?> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required String bucket,
    String? path,
  }) async {
    try {
      if (!isAuthenticated()) {
        throw Exception('User not authenticated');
      }

      final storage = FirebaseStorage.instance;
      final userId = getCurrentUserId();
      final filePath = path ?? 'uploads/$userId/$fileName';

      debugPrint('Uploading file to Firebase Storage: $filePath');

      final ref = storage.ref().child(filePath);
      final uploadTask = ref.putData(Uint8List.fromList(fileBytes));

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('File upload error: $e');
      return null;
    }
  }

  /// Download file from Firebase Storage
  static Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      if (!isAuthenticated()) {
        throw Exception('User not authenticated');
      }

      final storage = FirebaseStorage.instance;
      debugPrint('Downloading file from Firebase Storage: $path');

      final ref = storage.ref().child(path);
      final data = await ref.getData();

      debugPrint('File downloaded successfully: ${data?.length} bytes');
      return data;
    } catch (e) {
      debugPrint('File download error: $e');
      return null;
    }
  }

  /// Get public URL for file from Firebase Storage
  static Future<String?> getPublicUrl({
    required String bucket,
    required String path,
  }) async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

      debugPrint('Generated public URL for: $path');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error getting public URL: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Get current user email
  static String? getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  /// Refresh authentication token
  static Future<bool> refreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.getIdToken(true); // Force refresh
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  /// Check if session is valid
  static Future<bool> isSessionValid() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to get a fresh token
        await user.getIdToken(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Session validation error: $e');
      return false;
    }
  }
}
