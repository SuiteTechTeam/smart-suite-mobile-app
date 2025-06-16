import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth_bloc.dart';
import '../viewmodels/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16), // Espacio superior
                      Icon(
                        Icons.hotel,
                        size: 80, // Tamaño reducido
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 11, 88, 98)
                            : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to Smart Suite!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Reducir padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10), // Reducir espaciado
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey), // Icono más pequeño
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'ID: ${state.user.id}',
                                      style: Theme.of(context).textTheme.bodySmall, // Texto más pequeño
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6), // Reducir espaciado
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16, color: Colors.grey), // Icono más pequeño
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Email: ${state.user.email}',
                                      style: Theme.of(context).textTheme.bodySmall, // Texto más pequeño
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),                      
                        ),
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Contenedor con ancho máximo para evitar desbordamiento horizontal
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildNavigationButton(
                      context,
                      'Reservations',
                      Icons.calendar_today,
                      () => Navigator.pushNamed(context, '/reservations'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNavigationButton(
                      context,
                      'Add Reservation',
                      Icons.add_circle,
                      () => Navigator.pushNamed(context, '/add-reservation'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildNavigationButton(
                      context,
                      'Hotel Management',
                      Icons.hotel,
                      () => Navigator.pushNamed(context, '/hotels'),
                    ),
                  ),
                  const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
