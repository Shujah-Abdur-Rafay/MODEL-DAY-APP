import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'token_storage_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _loading = false;
  bool _isInitialized = false;
  bool _connectivityTested = false;
  bool _profileCreationInProgress = false;

  User? get currentUser => _currentUser;
  bool get loading => _loading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal() {
    debugPrint('🔐 AuthService singleton constructor called');
    _init();
    // Initialize API client
    _initializeApiClient();
  }

  void _initializeApiClient() {
    try {
      // Import and initialize API client here if needed
      debugPrint('🔗 API Client initialization skipped for now');
    } catch (e) {
      debugPrint('❌ API Client initialization error: $e');
    }
  }

  // Factory constructor for Provider compatibility
  factory AuthService() {
    debugPrint('🔐 AuthService factory called - returning singleton');
    return instance;
  }

  void _init() async {
    try {
      debugPrint('🔄 AuthService._init() started');

      // Listen for auth state changes
      _auth.authStateChanges().listen((User? user) async {
        debugPrint('🔔 AuthService - Auth state changed');
        debugPrint('🔍 Previous user: ${_currentUser?.email ?? 'null'}');
        debugPrint('🔍 New user: ${user?.email ?? 'null'}');

        final previousUser = _currentUser;
        _currentUser = user;

        // Only process if the user actually changed
        if (previousUser?.uid != user?.uid) {
          debugPrint('✅ AuthService - User actually changed, processing...');
          if (user != null) {
            debugPrint('👤 User signed in: ${user.email}');
            // Create user profile if it doesn't exist
            await _createUserProfileIfNeeded(user);
          } else {
            debugPrint('👋 User signed out');
            await TokenStorageService.clearAll();
          }

          debugPrint('📢 AuthService - Notifying listeners...');
          notifyListeners();
        } else {
          debugPrint('⏭️ AuthService - Same user, skipping processing');
        }
      });

      // Check for existing user
      _currentUser = _auth.currentUser;
      debugPrint('🔍 AuthService - Initial user: ${_currentUser?.email ?? 'null'}');

      _isInitialized = true;
      debugPrint('✅ AuthService - Initialization complete');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Auth initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Create user profile in Firestore if it doesn't exist
  Future<void> _createUserProfileIfNeeded(User user) async {
    // Prevent multiple simultaneous profile creation attempts
    if (_profileCreationInProgress) {
      debugPrint('Profile creation already in progress, skipping...');
      return;
    }

    try {
      _profileCreationInProgress = true;
      debugPrint('Attempting to create/check user profile for: ${user.email}');

      // Test Firestore connectivity first (only once)
      if (!_connectivityTested) {
        await _testFirestoreConnectivity();
        _connectivityTested = true;
      }

      // Use direct Firestore calls for all platforms - simpler and more reliable
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint('User document exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'onboarding_tour_seen': false,
          'onboarding_completed': false,
        });
        debugPrint('User profile created for: ${user.email}');
      } else {
        debugPrint('User profile already exists for: ${user.email}');
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Don't rethrow - this is not critical for authentication
    } finally {
      _profileCreationInProgress = false;
    }
  }

  /// Test Firestore connectivity
  Future<void> _testFirestoreConnectivity() async {
    try {
      debugPrint('Testing Firestore connectivity...');

      // Try to write a simple test document
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connectivity')
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });

      debugPrint('✅ Firestore write test successful');

      // Try to read it back
      final testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc('connectivity')
          .get();

      debugPrint('✅ Firestore read test successful: ${testDoc.exists}');

    } catch (e) {
      debugPrint('❌ Firestore connectivity test failed: $e');
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('Attempting to sign up with email: ${email.split('@')[0]}@...');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      _currentUser = credential.user;

      // Update display name if provided
      if (fullName != null && fullName.trim().isNotEmpty) {
        await _currentUser!.updateDisplayName(fullName.trim());
        await _currentUser!.reload();
        _currentUser = _auth.currentUser;
      }

      debugPrint('Sign up successful for user: ${_currentUser?.uid}');

      _loading = false;
      notifyListeners();

      // Don't navigate here - let the auth state listener handle navigation
    } catch (e) {
      debugPrint('Sign up error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      _loading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      _currentUser = credential.user;

      debugPrint('Sign in successful for user: ${_currentUser?.email}');

      _loading = false;
      notifyListeners();

      // Don't navigate here - let the auth state listener handle navigation
    } catch (e) {
      debugPrint('Sign in error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final credential = await _auth.signInWithPopup(googleProvider);
        _currentUser = credential.user;
      } else {
        // Mobile implementation
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign in cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        _currentUser = userCredential.user;
      }

      debugPrint('Google sign in successful for user: ${_currentUser?.email}');

      _loading = false;
      notifyListeners();

      // Don't navigate here - let the auth state listener handle navigation
    } catch (e) {
      debugPrint('Google sign in error: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await TokenStorageService.clearAll();
      await _auth.signOut();
      
      // Also sign out from Google if needed
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }

      _currentUser = null;
      notifyListeners();

      navigatorKey.currentState?.pushReplacementNamed('/');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Check if user has seen onboarding tour
  Future<bool> hasSeenOnboardingTour() async {
    try {
      if (_currentUser == null) return false;

      // Use direct Firestore calls for all platforms
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      final data = userDoc.data();
      if (data is Map<String, dynamic>) {
        return data['onboarding_tour_seen'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking onboarding tour status: $e');
      return false;
    }
  }

  /// Mark onboarding tour as seen
  Future<void> markOnboardingTourAsSeen() async {
    try {
      if (_currentUser == null) return;

      // Use direct Firestore calls for all platforms
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'onboarding_tour_seen': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Onboarding tour marked as seen');
    } catch (e) {
      debugPrint('Error marking onboarding tour as seen: $e');
      rethrow;
    }
  }

  /// Update onboarding completion status
  Future<void> updateOnboardingCompleted(bool completed) async {
    try {
      if (_currentUser == null) return;

      // Use direct Firestore calls for all platforms
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'onboarding_completed': completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Onboarding completion updated: $completed');
    } catch (e) {
      debugPrint('Error updating onboarding completion: $e');
      rethrow;
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      if (_currentUser == null) return false;

      // Use direct Firestore calls for all platforms
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      final data = userDoc.data();
      if (data is Map<String, dynamic>) {
        return data['onboarding_completed'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking onboarding completion: $e');
      return false;
    }
  }

  /// Update user profile data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) return;

      final updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
        ...data,
      };

      // Use direct Firestore calls for all platforms
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      debugPrint('User data updated successfully');
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_currentUser == null) return null;

      // Use direct Firestore calls for all platforms
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      final data = userDoc.data();
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
}
