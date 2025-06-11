# Core Configuration Documentation

## Overview

The core configuration system centralizes all API endpoints, constants, and configuration values used throughout the Smart Suite mobile application. This prevents code duplication and makes it easier to manage different environments and API changes.

## Structure

```
lib/core/
├── core.dart                    # Main export file
├── config/
│   └── app_config.dart         # API endpoints and app configuration
├── constants/
│   └── app_constants.dart      # Application constants
└── services/
    └── example_service.dart    # Example implementation
```

## Usage

### Importing Core Configuration

```dart
import '../../core/core.dart';
```

This single import gives you access to:
- `AppConfig` - All API endpoints and configuration
- `AppConstants` - Application constants like storage keys, error messages, HTTP status codes
- `ExampleService` - Reference implementation

### Available API Endpoints

#### Smart Suite API (IAM/Authentication)
```dart
AppConfig.smartSuiteBaseUrl           // http://smart-suite-web-service.azurewebsites.net
AppConfig.smartSuiteApiBaseUrl        // http://smart-suite-web-service.azurewebsites.net/api/v1
```

#### Sweet Manager API (Business Logic)
```dart
AppConfig.sweetManagerBaseUrl         // https://sweetmanager-api.ryzeon.me
AppConfig.sweetManagerApiBaseUrl      // https://sweetmanager-api.ryzeon.me/api/v1

// Specific endpoints
AppConfig.authenticationUrl           // Authentication operations
AppConfig.hotelApiUrl                 // Hotel management
AppConfig.roomApiUrl                  // Room management  
AppConfig.bookingApiUrl              // Booking management
AppConfig.userApiUrl                 // User management
AppConfig.providerApiUrl             // Provider management
AppConfig.supplyApiUrl               // Supply management
AppConfig.customerApiUrl             // Customer management
AppConfig.workerAreaApiUrl           // Worker area management
AppConfig.assignmentWorkerApiUrl     // Assignment worker operations
AppConfig.reportsApiUrl              // Reports and analytics
```

### Common Constants

```dart
// Storage keys
AppConstants.authTokenKey
AppConstants.refreshTokenKey
AppConstants.userDataKey
AppConstants.isLoggedInKey

// HTTP status codes
AppConstants.httpOk                   // 200
AppConstants.httpCreated              // 201
AppConstants.httpBadRequest           // 400
AppConstants.httpUnauthorized         // 401
AppConstants.httpNotFound             // 404
AppConstants.httpInternalServerError  // 500

// Error messages (in Spanish)
AppConstants.genericErrorMessage
AppConstants.networkErrorMessage
AppConstants.unauthorizedErrorMessage
AppConstants.validationErrorMessage
```

## Migration Guide

### Before (Hardcoded URLs)
```dart
class HotelService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/hotel';
  
  Future<List<Hotel>> fetchHotels() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    // ...
  }
}
```

### After (Using Core Configuration)
```dart
import '../../core/core.dart';

class HotelService {
  final String baseUrl = AppConfig.hotelApiUrl;
  
  Future<List<Hotel>> fetchHotels() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    
    if (response.statusCode == AppConstants.httpOk) {
      // ...
    }
  }
}
```

### For Authentication Services
```dart
import '../../core/core.dart';

class AuthService {
  final String baseUrl = AppConfig.authenticationUrl;
  
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == AppConstants.httpOk) {
      final data = jsonDecode(response.body);
      await storage.write(key: AppConstants.authTokenKey, value: data['token']);
      return true;
    }
    return false;
  }
}
```

## Best Practices

1. **Always use core configuration**: Never hardcode URLs or constants in service files
2. **Import from core**: Use `import '../../core/core.dart'` instead of individual imports
3. **Use appropriate endpoints**: Choose the right endpoint (Smart Suite vs Sweet Manager) for your use case
4. **Use constants for status codes**: Replace magic numbers with `AppConstants.httpOk`, etc.
5. **Use storage key constants**: Use `AppConstants.authTokenKey` instead of hardcoded 'token' strings

## Environment Configuration

Currently, the configuration is set for production. In the future, this can be enhanced to support multiple environments:

```dart
// Future enhancement
static String get baseUrl {
  switch (environment) {
    case 'development':
      return 'http://localhost:8080';
    case 'staging':
      return 'https://staging-api.smartsuite.com';
    default:
      return 'https://smartsuite-api.com';
  }
}
```

## Files to Update

When migrating existing services, look for these patterns and replace them:

- `'https://sweetmanager-api.ryzeon.me'` → `AppConfig.sweetManagerBaseUrl`
- `'http://smart-suite-web-service.azurewebsites.net'` → `AppConfig.smartSuiteBaseUrl`
- `'token'` → `AppConstants.authTokenKey`
- `200` → `AppConstants.httpOk`
- `401` → `AppConstants.httpUnauthorized`

### Priority Files for Migration
1. All service files in `lib/Profiles/*/services/`
2. All service files in `lib/*/services/`
3. Authentication related files
4. HTTP client implementations

## Questions or Issues?

If you encounter any issues while migrating to the core configuration system, please:
1. Check the `ExampleService` for reference implementation
2. Ensure you're importing `'../../core/core.dart'`
3. Verify the endpoint you're using matches your API requirements
4. Check that constants are spelled correctly (they're case-sensitive)
