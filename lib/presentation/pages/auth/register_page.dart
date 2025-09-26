import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../infrastructure/core/injection.dart' as di;
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/presentation_injection.dart';

/// Registration page for new users
/// Allows creating accounts with different kitchen roles
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di.getIt.authBloc,
      child: const RegisterView(),
    );
  }
}

/// Registration view with comprehensive form
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.lineCook;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is RegistrationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back to login or dashboard
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Name field
                  _buildNameField(),
                  const SizedBox(height: 16),

                  // Email field
                  _buildEmailField(),
                  const SizedBox(height: 16),

                  // Role selector
                  _buildRoleSelector(),
                  const SizedBox(height: 16),

                  // Password field
                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  // Confirm password field
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),

                  // Register button
                  _buildRegisterButton(context),
                  const SizedBox(height: 16),

                  // Login link
                  _buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join the kitchen team',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email address',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!_isValidEmail(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<UserRole>(
      initialValue: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Kitchen Role',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _getAvailableRoles().map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(_getRoleDisplayName(role)),
        );
      }).toList(),
      onChanged: (UserRole? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedRole = newValue;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select your role';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a secure password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleRegister(context),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return ElevatedButton(
          onPressed: isLoading ? null : () => _handleRegister(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.orange[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<UserRole> _getAvailableRoles() {
    // Return roles that can be selected during registration
    // Typically excluding admin and high-level management roles
    return [
      UserRole.dishwasher,
      UserRole.prepCook,
      UserRole.lineCook,
      UserRole.cook,
      UserRole.cookSenior,
      UserRole.chefAssistant,
      UserRole.expediter,
    ];
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return 'Dishwasher';
      case UserRole.prepCook:
        return 'Prep Cook';
      case UserRole.lineCook:
        return 'Line Cook';
      case UserRole.cook:
        return 'Cook';
      case UserRole.cookSenior:
        return 'Senior Cook';
      case UserRole.chefAssistant:
        return 'Chef Assistant';
      case UserRole.sousChef:
        return 'Sous Chef';
      case UserRole.chefHead:
        return 'Head Chef';
      case UserRole.expediter:
        return 'Expediter';
      case UserRole.kitchenManager:
        return 'Kitchen Manager';
      case UserRole.generalManager:
        return 'General Manager';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      context.read<AuthBloc>().add(
        RegisterEvent(
          name: name,
          email: email,
          password: password,
          role: _selectedRole
              .toString()
              .split('.')
              .last, // Convert enum to string
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
