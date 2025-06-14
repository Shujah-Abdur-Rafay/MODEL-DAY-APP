import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _lastLoginKey = 'last_login';

  // Use secure storage for production, shared preferences for debug/web
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save authentication tokens securely
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
    DateTime? expiresAt,
  }) async {
    try {
      final now = DateTime.now();

      if (kIsWeb || kDebugMode) {
        // Use SharedPreferences for web and debug mode
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, accessToken);
        if (refreshToken != null) {
          await prefs.setString(_refreshTokenKey, refreshToken);
        }
        await prefs.setString(_userDataKey, jsonEncode(userData));
        if (expiresAt != null) {
          await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
        }
        await prefs.setString(_lastLoginKey, now.toIso8601String());
      } else {
        // Use secure storage for mobile production
        await _secureStorage.write(key: _accessTokenKey, value: accessToken);
        if (refreshToken != null) {
          await _secureStorage.write(
              key: _refreshTokenKey, value: refreshToken);
        }
        await _secureStorage.write(
            key: _userDataKey, value: jsonEncode(userData));
        if (expiresAt != null) {
          await _secureStorage.write(
              key: _tokenExpiryKey, value: expiresAt.toIso8601String());
        }
        await _secureStorage.write(
            key: _lastLoginKey, value: now.toIso8601String());
      }

      debugPrint('Tokens saved successfully');
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      rethrow;
    }
  }

  /// Get stored access token
  static Future<String?> getAccessToken() async {
    try {
      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_accessTokenKey);
      } else {
        return await _secureStorage.read(key: _accessTokenKey);
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_refreshTokenKey);
      } else {
        return await _secureStorage.read(key: _refreshTokenKey);
      }
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      return null;
    }
  }

  /// Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      String? userDataString;

      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        userDataString = prefs.getString(_userDataKey);
      } else {
        userDataString = await _secureStorage.read(key: _userDataKey);
      }

      if (userDataString == null) return null;

      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      String? expiryString;

      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        expiryString = prefs.getString(_tokenExpiryKey);
      } else {
        expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      }

      if (expiryString == null) return true; // No expiry set, assume expired

      final expiryDate = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return true; // Assume expired on error
    }
  }

  /// Get last login time
  static Future<DateTime?> getLastLoginTime() async {
    try {
      String? lastLoginString;

      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        lastLoginString = prefs.getString(_lastLoginKey);
      } else {
        lastLoginString = await _secureStorage.read(key: _lastLoginKey);
      }

      if (lastLoginString == null) return null;

      return DateTime.parse(lastLoginString);
    } catch (e) {
      debugPrint('Error getting last login time: $e');
      return null;
    }
  }

  /// Check if user has valid stored session
  static Future<bool> hasValidSession() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return false;

      final isExpired = await isTokenExpired();
      return !isExpired;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  /// Clear all stored tokens and user data
  static Future<void> clearAll() async {
    try {
      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userDataKey);
        await prefs.remove(_tokenExpiryKey);
        await prefs.remove(_lastLoginKey);
      } else {
        await _secureStorage.delete(key: _accessTokenKey);
        await _secureStorage.delete(key: _refreshTokenKey);
        await _secureStorage.delete(key: _userDataKey);
        await _secureStorage.delete(key: _tokenExpiryKey);
        await _secureStorage.delete(key: _lastLoginKey);
      }

      debugPrint('All tokens cleared successfully');
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
      rethrow;
    }
  }

  /// Update only the access token (for token refresh)
  static Future<void> updateAccessToken(String newAccessToken,
      {DateTime? expiresAt}) async {
    try {
      if (kIsWeb || kDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, newAccessToken);
        if (expiresAt != null) {
          await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
        }
      } else {
        await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
        if (expiresAt != null) {
          await _secureStorage.write(
              key: _tokenExpiryKey, value: expiresAt.toIso8601String());
        }
      }

      debugPrint('Access token updated successfully');
    } catch (e) {
      debugPrint('Error updating access token: $e');
      rethrow;
    }
  }

  /// Get all stored authentication data
  static Future<Map<String, dynamic>?> getAllAuthData() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final userData = await getUserData();
      final lastLogin = await getLastLoginTime();
      final isExpired = await isTokenExpired();

      if (accessToken == null) return null;

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userData': userData,
        'lastLogin': lastLogin?.toIso8601String(),
        'isExpired': isExpired,
        'hasValidSession': !isExpired,
      };
    } catch (e) {
      debugPrint('Error getting all auth data: $e');
      return null;
    }
  }
}
