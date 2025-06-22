// To implement dark and light mode support app-wide, you should modify your app's main.dart file
// Below is an example implementation using ThemeMode and a ThemeController

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme controller to manage theme state
class ThemeController with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  
  late ThemeMode _themeMode;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeController() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);
    
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      // Default to system
      _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    String themeName;
    switch (mode) {
      case ThemeMode.dark:
        themeName = 'dark';
        break;
      case ThemeMode.light:
        themeName = 'light';
        break;
      case ThemeMode.system:
        themeName = 'system';
        break;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, themeName);
    
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

// Example app implementation with theme toggle
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    
    return MaterialApp(
      title: 'Smart Suite',
      themeMode: themeController.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardTheme(
          color: Colors.grey[850],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade700),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Then in your appbar, you can add a theme toggle button:
IconButton(
  icon: Icon(
    themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
    color: themeController.isDarkMode ? Colors.amber : Colors.indigo,
  ),
  onPressed: () {
    themeController.toggleTheme();
  },
),
*/
