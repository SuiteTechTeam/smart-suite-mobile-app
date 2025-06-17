import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'iam/services/auth_api_service.dart';
import 'iam/services/storage_service.dart';
import 'iam/services/auth_repository.dart';
import 'iam/viewmodels/auth_bloc.dart';
import 'iam/viewmodels/auth_event.dart';
import 'iam/views/auth_wrapper.dart';
import 'iam/views/home_tab_navigation.dart';
import 'iam/views/login_page.dart';
import 'iam/views/debug_auth_screen.dart';
import 'booking/views/reservation_management_screen.dart';
import 'booking/views/add_reservation_screen.dart';
import 'hotels/views/hotel/hotel_management_screen.dart';
import 'booking/views/api_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for initialization
  try {
    runApp(const SmartSuiteApp());
  } catch (e, stackTrace) {
    debugPrint('Error starting app: $e');
    debugPrint('Stack trace: $stackTrace');
    // You could show a fallback error screen here if needed
    runApp(const SmartSuiteApp());
  }
}

class SmartSuiteApp extends StatelessWidget {
  const SmartSuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final apiService = AuthApiService();
    final authRepository = AuthRepository(
      apiService: apiService,
      storageService: storageService,
    );

    return BlocProvider(
      create: (context) =>
          AuthBloc(authRepository: authRepository)..add(AuthStatusChecked()),
      child: MaterialApp(
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomeTabNavigation(),
          '/reservations': (context) => const ReservationManagementScreen(),
          '/add-reservation': (context) => const AddReservationScreen(),
          '/reservations/add': (context) => const AddReservationScreen(),
          '/hotels': (context) => const HotelManagementScreen(),
          '/api-test': (context) => const ApiTestScreen(),
          '/debug-auth': (context) => const DebugAuthScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/reservations/add') {
            return MaterialPageRoute(
              builder: (context) => const AddReservationScreen(),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const HomeTabNavigation(),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
      ),
    );
  }
}

class ModernLoadingScreen extends StatefulWidget {
  const ModernLoadingScreen({super.key});

  @override
  State<ModernLoadingScreen> createState() => _ModernLoadingScreenState();
}

class _ModernLoadingScreenState extends State<ModernLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3), Color(0xFF03DAC6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.2),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hotel_rounded,
                        size: 50,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Smart Suite',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cargando tu experiencia...',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ModernErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Intentar de nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
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
