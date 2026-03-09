import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  
  bool _stepTwo = false;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _verifyEmailAndProceed() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoadingLocal = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final exists = await auth.checkEmailExists(_emailController.text.trim());

    if (!mounted) return;

    if (exists) {
      setState(() {
        _stepTwo = true;
        _isLoadingLocal = false;
      });
    } else {
      setState(() {
        _errorMessage = 'No account found for that email address';
        _isLoadingLocal = false;
      });
    }
  }

  bool _isLoadingLocal = false;

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    final auth = context.read<AuthProvider>();
    final error = await auth.updatePassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please login again.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading || _isLoadingLocal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_stepTwo) {
              setState(() => _stepTwo = false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_stepTwo),
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_reset, size: 64, color: Color(0xFFE60A15)),
                      const SizedBox(height: 24),
                      Text(
                        _stepTwo ? 'Set New Password' : 'Reset Password',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stepTwo 
                            ? 'Enter your new secure password combination below.'
                            : 'Enter your account email. We will verify your account to proceed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 48),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE60A15).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE60A15).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFE60A15), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFFE60A15), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // STEP 1: Email Input
                      if (!_stepTwo)
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'name@company.com',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.5)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                      // STEP 2: Password Inputs
                      if (_stepTwo) ...[
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPass,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'New Password',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPass ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPass,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Confirm New Password',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Please confirm your password' : null,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: isLoading ? null : (_stepTwo ? _submitReset : _verifyEmailAndProceed),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE60A15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _stepTwo ? 'UPDATE PASSWORD' : 'CONTINUE',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
