import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth_bloc.dart';
import '../viewmodels/auth_event.dart';
import '../viewmodels/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Suite'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(AuthSignOutRequested());
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hotel,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Smart Suite!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'User Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'ID: ${state.user.id}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Email: ${state.user.email}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),                      ),
                      const SizedBox(height: 24),
                      _buildNavigationSection(context),
                      const SizedBox(height: 32),
                      Text(
                        'JWT Token is stored and ready for API calls!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),            const SizedBox(height: 16),            Row(
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    'Reservations',
                    Icons.calendar_today,
                    () => Navigator.pushNamed(context, '/reservations'),
                  ),
                ),                const SizedBox(width: 12),                Expanded(
                  child: _buildNavigationButton(
                    context,
                    'Add Reservation',
                    Icons.add_circle,
                    () => Navigator.pushNamed(context, '/add-reservation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    'Hotel Management',
                    Icons.hotel,
                    () => Navigator.pushNamed(context, '/hotels'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    'API Test',
                    Icons.network_check,
                    () => Navigator.pushNamed(context, '/api-test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
