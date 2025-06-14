import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth_bloc.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/auth_event.dart';
import '../models/user_role.dart';
import '../services/auth_api_service.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _emailController = TextEditingController(text: 'itx.darkx@gmail.com');
  final _passwordController = TextEditingController(text: 'Yj?9khiu');
  UserRole _selectedRole = UserRole.owner; // roleId: 1
  bool _isTestingConnectivity = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: const Text('Debug Auth'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Current State: ${state.runtimeType}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (state is AuthError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (state is AuthAuthenticated) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'User: ${state.user.email}\nRole: ${state.user.role}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: state is AuthLoading ? null : () {
                    context.read<AuthBloc>().add(
                      AuthSignInRequested(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        role: _selectedRole,
                      ),
                    );
                  },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : const Text('Test Login'),
                ),                const SizedBox(height: 12),
                
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthStatusChecked());
                  },
                  child: const Text('Check Auth Status'),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton(
                  onPressed: _isTestingConnectivity ? null : () async {
                    setState(() {
                      _isTestingConnectivity = true;
                    });
                    
                    try {
                      final apiService = AuthApiService();
                      final isConnected = await apiService.testConnectivity();
                      
                      if (mounted) {                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isConnected 
                                  ? 'Connectivity test passed!' 
                                  : 'Connectivity test failed!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: isConnected ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Connectivity error: $e', style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isTestingConnectivity = false;
                        });
                      }
                    }
                  },
                  child: _isTestingConnectivity
                      ? const CircularProgressIndicator()
                      : const Text('Test Connectivity'),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '1. Check the debug console for detailed logs\n'
                  '2. Try "Check Auth Status" first\n'
                  '3. Try "Test Login" with valid credentials\n'
                  '4. Monitor the state changes above',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
