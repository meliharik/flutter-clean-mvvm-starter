import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen
///
/// MVVM PATTERN DEMONSTRATION:
/// - View: This widget (displays UI)
/// - ViewModel: AuthNotifier (manages state, business logic)
/// - Model: AuthState (data structure)
///
/// RIVERPOD PATTERN:
/// - ConsumerWidget: Can read providers
/// - ref.watch: Rebuild when state changes
/// - ref.read: One-time access (for callbacks)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Call ViewModel method
      ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for changes
    final authState = ref.watch(authNotifierProvider);

    // Listen for state changes to show snackbars
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.userMessage),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App branding
              const Icon(Icons.lock_outline, size: 80),
              const SizedBox(height: 32),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Login button
              // WHY .when: Pattern match on state, show loading or button
              authState.when(
                initial: () => _buildLoginButton(),
                loading: () => const Center(child: CircularProgressIndicator()),
                authenticated: (_) => _buildLoginButton(),
                unauthenticated: () => _buildLoginButton(),
                error: (_) => _buildLoginButton(),
              ),

              const SizedBox(height: 16),

              // Demo credentials hint
              const Text(
                'Demo: Use any email/password (API not connected)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('Login', style: TextStyle(fontSize: 16)),
    );
  }
}
