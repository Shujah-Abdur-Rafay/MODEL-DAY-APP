import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/services/logger_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _error = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔑 SignUpPage.initState() called');
  }

  @override
  void dispose() {
    debugPrint('🗑️ SignUpPage.dispose() called');
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    debugPrint('🔑 SignUpPage._handleSignUp() called');
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _error = 'Please agree to the Terms and Conditions';
      });
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      debugPrint('🔄 SignUpPage - Attempting sign up...');
      await context.read<AuthService>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          );
      debugPrint('✅ SignUpPage - Sign up successful');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome to ModelDay!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to welcome page after successful signup
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ SignUpPage - Sign up failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to create account. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    debugPrint('🔑 SignUpPage._handleGoogleSignUp() called');
    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      debugPrint('🔄 SignUpPage - Attempting Google sign up...');
      await context.read<AuthService>().signInWithGoogle();
      debugPrint('✅ SignUpPage - Google sign up successful');

      if (mounted) {
        // Navigate to welcome page after successful Google signup
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ SignUpPage - Google sign up failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to sign up with Google. Please try again.';
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  // Add cursor styling for better visibility
                  cursorColor: AppTheme.goldColor,
                  cursorWidth: 2.0,
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

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
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
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
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
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                      debugPrint(
                          '👁️ Confirm password visibility toggled: ${!_obscureConfirmPassword}');
                    },
                    child: Center(
                      child: Text(
                        _obscureConfirmPassword ? '👁️' : '🙈',
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
    debugPrint('🏗️ SignUpPage.build() called');

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

                      // Sign Up Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Create an account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Join Model Day and take your modeling career to the next level',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Google Sign Up Button
                            OutlinedButton.icon(
                              onPressed:
                                  _isLoading ? null : _handleGoogleSignUp,
                              icon: const Icon(
                                Icons.g_mobiledata,
                                size: 20,
                              ),
                              label: const Text('Sign up with Google'),
                              style: AppTheme.outlineButtonStyle,
                            ),
                            const SizedBox(height: 24),

                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 24),

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

                            // Sign Up Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _fullNameController,
                                    decoration:
                                        AppTheme.textFieldDecoration.copyWith(
                                      labelText: 'Full Name',
                                      hintText: 'Enter your full name',
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPasswordField(),
                                  const SizedBox(height: 16),
                                  _buildConfirmPasswordField(),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(
                                              () => _agreeToTerms = value!);
                                        },
                                        activeColor: AppTheme.goldColor,
                                      ),
                                      const Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style:
                                                TextStyle(color: Colors.grey),
                                            children: [
                                              TextSpan(
                                                text: 'Terms and Conditions',
                                                style: TextStyle(
                                                  color: AppTheme.goldColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _handleSignUp,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.person_add),
                                    label: Text(
                                      _isLoading
                                          ? 'Creating account...'
                                          : 'Create Account',
                                    ),
                                    style: AppTheme.primaryButtonStyle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signin',
                                    );
                                  },
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(color: AppTheme.goldColor),
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
