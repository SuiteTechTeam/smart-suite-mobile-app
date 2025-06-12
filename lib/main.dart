import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'iam/services/auth_api_service.dart';
import 'iam/services/storage_service.dart';
import 'iam/services/auth_repository.dart';
import 'iam/viewmodels/auth_bloc.dart';
import 'iam/viewmodels/auth_event.dart';
import 'iam/viewmodels/auth_state.dart';
import 'iam/views/login_page.dart';
import 'iam/views/home_page.dart';
import 'iam/views/auth_wrapper.dart';
import 'reservations/views/reservation_management_screen.dart';
import 'reservations/views/add_reservation_screen.dart';
import 'hotels/views/hotel_management_screen.dart';
import 'reservations/views/api_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartSuiteApp());
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
        title: 'Smart Suite',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomeTabNavigation(),
          '/reservations': (context) => const ReservationManagementScreen(),
          '/add-reservation': (context) => const AddReservationScreen(),
          '/reservations/add': (context) => const AddReservationScreen(),
          '/hotels': (context) => const HotelManagementScreen(),
          '/api-test': (context) => const ApiTestScreen(),
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
          return MaterialPageRoute(builder: (context) => const HomeTabNavigation());
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeTabNavigation extends StatefulWidget {
  const HomeTabNavigation({super.key});

  @override
  State<HomeTabNavigation> createState() => _HomeTabNavigationState();
}

class _HomeTabNavigationState extends State<HomeTabNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HotelManagementScreen(),
    ReservationManagementScreen(),
    ApiTestScreen(),
  ];

  static const List<String> _titles = <String>[
    'Home',
    'Hotels',
    'Reservations',
    'Test API',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Hotels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.api),
            label: 'Test API',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const HotelLoadingScreen();
        } else if (state is AuthAuthenticated) {
          return const HomeTabNavigation();
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
