import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/logger_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🔑 SignInPage.initState() called');
  }

  @override
  void dispose() {
    debugPrint('🗑️ SignInPage.dispose() called');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    debugPrint('🔑 SignInPage._handleSignIn() called');
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      debugPrint('🔄 SignInPage - Attempting sign in...');
      await context.read<AuthService>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      debugPrint('✅ SignInPage - Sign in successful, navigating to welcome');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      debugPrint('❌ SignInPage - Sign in failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Invalid email or password. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('🔑 SignInPage._handleGoogleSignIn() called');
    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      debugPrint('🔄 SignInPage - Attempting Google sign in...');
      await context.read<AuthService>().signInWithGoogle();
      debugPrint(
          '✅ SignInPage - Google sign in successful, navigating to welcome');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      debugPrint('❌ SignInPage - Google sign in failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to sign in with Google. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async => await _handleSignIn(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  // Add cursor styling for better visibility
                  cursorColor: AppTheme.goldColor,
                  cursorWidth: 2.0,
                  cursorHeight: 20.0,
                  showCursor: true,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                      debugPrint(
                          '👁️ Password visibility toggled: ${!_obscurePassword}');
                    },
                    child: Center(
                      child: Text(
                        _obscurePassword ? '👁️' : '🙈',
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ SignInPage.build() called');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      LoggerService.info('🔥 Back button clicked!');
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/model_day_logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.goldColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    'M',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms),

                      const SizedBox(height: 32),

                      // Sign In Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome back to Model Day',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Error Message
                            if (_error.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_error.isNotEmpty) const SizedBox(height: 16),

                            // Sign In Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Email',
                                      hintText: 'name@example.com',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.white),
                                    // Add cursor styling for better visibility
                                    cursorColor: AppTheme.goldColor,
                                    cursorWidth: 2.0,
                                    showCursor: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPasswordField(),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/forgot-password');
                                      },
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                            color: AppTheme.goldColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _handleSignIn,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.login),
                                    label: Text(
                                      _isLoading ? 'Signing in...' : 'Sign In',
                                    ),
                                    style: AppTheme.primaryButtonStyle,
                                  ),
                                  const SizedBox(height: 24),
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: Divider(color: Colors.grey)),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                          child: Divider(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _handleGoogleSignIn,
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      size: 20,
                                    ),
                                    label: const Text('Sign in with Google'),
                                    style: AppTheme.outlineButtonStyle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Flexible(
                                  child: Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/signup',
                                      );
                                    },
                                    child: const Text(
                                      'Sign up',
                                      style:
                                          TextStyle(color: AppTheme.goldColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
