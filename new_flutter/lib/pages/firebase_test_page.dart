import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_layout.dart';
import '../widgets/ui/button.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _connectionStatus = 'Not tested';
  String _userStatus = 'Not checked';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();

      // Test Firebase connection
      setState(() {
        _connectionStatus = 'Connected to Firebase';
      });

      // Test user authentication
      final user = authService.currentUser;
      setState(() {
        _userStatus = user != null
            ? 'Authenticated as: ${user.email}'
            : 'Not authenticated';
      });

    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignUp() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = context.read<AuthService>();
      await authService.signUp(
        email: 'test@example.com',
        password: 'test123',
        fullName: 'Test User',
      );

      setState(() {
        _userStatus = 'Test user created successfully';
      });
    } catch (e) {
      setState(() {
        _userStatus = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = context.read<AuthService>();
      await authService.signIn(
        email: 'test@example.com',
        password: 'test123',
      );

      setState(() {
        _userStatus = 'Sign in successful';
      });
    } catch (e) {
      setState(() {
        _userStatus = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = context.read<AuthService>();
      await authService.signOut();

      setState(() {
        _userStatus = 'Signed out successfully';
      });
    } catch (e) {
      setState(() {
        _userStatus = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/firebase-test',
      title: 'Firebase Test',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Connection Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Connection Status
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        color: _connectionStatus.contains('failed')
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Status
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userStatus,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      onPressed: _testSignUp,
                      text: 'Test Sign Up',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      onPressed: _testSignIn,
                      text: 'Test Sign In',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      onPressed: _testSignOut,
                      text: 'Test Sign Out',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      onPressed: _testConnection,
                      text: 'Refresh Status',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
