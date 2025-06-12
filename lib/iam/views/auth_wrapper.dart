import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_suite/iam/viewmodels/auth_event.dart';
import '../viewmodels/auth_bloc.dart';
import '../viewmodels/auth_state.dart';
import 'login_page.dart';
import 'home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const HotelLoadingScreen();
        } else if (state is AuthAuthenticated) {
          return const HomePage();
        } else if (state is AuthError) {
          return HotelErrorScreen(
            message: state.message,
            onRetry: () {
              context.read<AuthBloc>().add(AuthStatusChecked());
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class HotelLoadingScreen extends StatefulWidget {
  const HotelLoadingScreen({super.key});

  @override
  State<HotelLoadingScreen> createState() => _HotelLoadingScreenState();
}

class _HotelLoadingScreenState extends State<HotelLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _iotController;
  late AnimationController _fadeController;
  late AnimationController _buildingController;

  late Animation<double> _waveAnimation;
  late Animation<double> _iotAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buildingAnimation;

  final List<String> _loadingMessages = [
    'Conectando con el sistema hotelero...',
    'Sincronizando dispositivos IoT...',
    'Verificando sensores de habitaciones...',
    'Estableciendo conexión segura...',
    'Cargando panel de control...',
  ];

  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _iotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buildingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _iotAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _iotController, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _buildingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buildingController, curve: Curves.easeOutBack),
    );

    _waveController.repeat();
    _iotController.repeat(reverse: true);
    _fadeController.forward();
    _buildingController.forward();

    // Cambiar mensajes cada 2 segundos
    _startMessageRotation();
  }

  void _startMessageRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _iotController.dispose();
    _fadeController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0D1421),
                    const Color(0xFF1A252F),
                    const Color(0xFF2C3A47),
                  ]
                : [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF3B82F6),
                    const Color(0xFF60A5FA),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo del hotel con animación de edificio
                  AnimatedBuilder(
                    animation: _buildingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _buildingAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber.withValues(alpha: 0.3),
                                Colors.orange.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Edificio del hotel
                              const Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.white,
                              ),
                              // Ondas IoT animadas
                              AnimatedBuilder(
                                animation: _waveAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: const Size(120, 120),
                                    painter: IoTWavesPainter(
                                      animationValue: _waveAnimation.value,
                                      color: Colors.amber.withValues(alpha: 0.6),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Título de la app
                  Text(
                    'HotelSmart',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'IoT Management System',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.amber.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Indicadores de dispositivos IoT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _IoTDeviceIndicator(
                        icon: Icons.thermostat,
                        label: 'Clima',
                        animation: _iotAnimation,
                        color: Colors.blue,
                      ),
                      _IoTDeviceIndicator(
                        icon: Icons.lightbulb_outline,
                        label: 'Luces',
                        animation: _iotAnimation,
                        color: Colors.yellow,
                        delay: 0.2,
                      ),
                      _IoTDeviceIndicator(
                        icon: Icons.lock_outline,
                        label: 'Acceso',
                        animation: _iotAnimation,
                        color: Colors.green,
                        delay: 0.4,
                      ),
                      _IoTDeviceIndicator(
                        icon: Icons.sensors,
                        label: 'Sensores',
                        animation: _iotAnimation,
                        color: Colors.purple,
                        delay: 0.6,
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Barra de progreso hotelera
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Mensaje de carga dinámico
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _loadingMessages[_currentMessageIndex],
                            key: ValueKey(_currentMessageIndex),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Barra de progreso personalizada
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.amber.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer con versión
                  Text(
                    'Conectando a la Suite IoT v2.1',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IoTDeviceIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Animation<double> animation;
  final Color color;
  final double delay;

  const _IoTDeviceIndicator({
    required this.icon,
    required this.label,
    required this.animation,
    required this.color,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final delayedValue = ((animation.value + delay) % 1.0);
        final scale = 0.8 + (delayedValue * 0.3);

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5), 
                    width: 2
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IoTWavesPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  IoTWavesPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Dibujar ondas concéntricas
    for (int i = 0; i < 3; i++) {
      final radius = (20 + i * 15) * (1 + animationValue * 0.5);
      final opacity = 1.0 - (animationValue + i * 0.3) % 1.0;

      paint.color = color.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HotelErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HotelErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
                : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de hotel con error
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.business, size: 50, color: Colors.white),
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Error de Conexión',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sistema IoT Hotelero',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de reconectar
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reconectar Sistema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    // Aquí podrías agregar navegación a soporte técnico
                    // Navigator.pushNamed(context, '/support');
                  },
                  child: Text(
                    'Contactar Soporte Técnico',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
