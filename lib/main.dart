import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_suite/core/views/home_tab_navigation.dart';
import 'iam/services/auth_api_service.dart';
import 'iam/services/storage_service.dart';
import 'iam/services/auth_repository.dart';
import 'iam/viewmodels/auth_bloc.dart';
import 'iam/viewmodels/auth_event.dart';
import 'iam/views/auth_wrapper.dart';
import 'iam/views/login_page.dart';
import 'core/views/debug_auth_screen.dart';
import 'booking/views/reservation_management_screen.dart';
import 'booking/views/add_reservation_screen.dart';
import 'hotels/views/hotel/hotel_management_screen.dart';
import 'core/views/api_test_screen.dart';

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
          '/add-reservation': (context) => const AddReservationScreen(),
          '/reservations/add': (context) => const AddReservationScreen(),
          '/hotels': (context) => const HotelManagementScreen(),
          '/api-test': (context) => const ApiTestScreen(),
          '/debug-auth': (context) => const DebugAuthScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/reservations') {
            final args = settings.arguments as Map<String, dynamic>?;
            final hotelId = args != null ? args['hotelId'] as int? : null;
            return MaterialPageRoute(
              builder: (context) => ReservationManagementScreen(hotelId: hotelId),
            );
          }
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
