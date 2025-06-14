import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_suite/hotels/utils/hotel_utils.dart';
import '../../hotels/services/hotel_service.dart';
import '../services/reservation_service.dart';
import '../utils/error_handler.dart';
import '../../iam/services/storage_service.dart';
import 'dart:io';
import '../models/reservation.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final HotelService _hotelService = HotelService();
  final ReservationService _reservationService = ReservationService();
  final storage = const FlutterSecureStorage();
  
  List<Map<String, dynamic>> testResults = [];
  bool isRunningTests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Connectivity Tests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool tests connectivity to the Smart Suite API endpoints to ensure they are working properly.',
                    ),
                    const SizedBox(height: 16),                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isRunningTests ? null : _runAllTests,
                        child: isRunningTests
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Running Tests...'),
                                ],
                              )
                            : const Text('Run Connectivity Tests'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: isRunningTests ? null : _testHotelCreationOnly,
                        child: const Text('Test Hotel Creation Only'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (testResults.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: testResults.length,
                itemBuilder: (context, index) {
                  final result = testResults[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        result['success'] as bool ? Icons.check_circle : Icons.error,
                        color: result['success'] as bool ? Colors.green : Colors.red,
                      ),
                      title: Text(result['test'] as String),
                      subtitle: Text(
                        result['message'] as String,
                        style: TextStyle(
                          color: result['success'] as bool 
                              ? Colors.green[700] 
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      isRunningTests = true;
      testResults.clear();
    });

    // Test 0: Check internet connectivity
    await _testInternetConnectivity();

    // Test 1: Check if we have a valid token
    await _testTokenAvailability();

    // Test 1.5: Test StorageService vs Direct Storage comparison  
    await _testStorageServiceVsDirectStorage();

    // Test 2: Test basic API endpoint reachability
    await _testAPIReachability();

    // Test 3: Test hotel service - get all hotels
    await _testGetAllHotels();

    // Test 4: Test hotel validation with a known hotel ID
    await _testHotelValidation();

    // Test 5: Test reservation service
    await _testReservationService();

    // Test 6: Test hotel creation (if user is owner)
    await _testHotelCreation();

    setState(() {
      isRunningTests = false;
    });

    _showTestSummary();
  }

  Future<void> _testInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 10),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _addTestResult('Internet Connectivity', true, 'Internet connection available');
      } else {
        _addTestResult('Internet Connectivity', false, 'No internet connection');
      }
    } catch (e) {
      _addTestResult('Internet Connectivity', false, 'Failed to check internet: $e');
    }
  }

  Future<void> _testAPIReachability() async {
    try {
      final result = await InternetAddress.lookup('smart-suite-web-service.azurewebsites.net').timeout(
        const Duration(seconds: 15),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _addTestResult('API Server Reachability', true, 'API server is reachable');
      } else {
        _addTestResult('API Server Reachability', false, 'API server not reachable');
      }
    } catch (e) {
      _addTestResult('API Server Reachability', false, 'Cannot reach API server: $e');
    }
  }

  Future<void> _testTokenAvailability() async {
    try {
      String? token = await storage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        // Check if token is expired
        bool isExpired = false;
        String tokenDetails = '';
        
        try {
          isExpired = JwtDecoder.isExpired(token);
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          
          // Get some basic info from token
          String? role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          String? email = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
          String? userId = decodedToken['sub'];
          
          tokenDetails = 'Role: $role, Email: $email, UserID: $userId';
        } catch (e) {
          tokenDetails = 'Token parsing failed: $e';
          isExpired = true;
        }
        
        if (isExpired) {
          _addTestResult('Token Availability', false, 'Token found but EXPIRED - please login again. $tokenDetails');
        } else {
          _addTestResult('Token Availability', true, 'Valid authentication token found. $tokenDetails');
        }
      } else {
        _addTestResult('Token Availability', false, 'No authentication token found - please login first');
      }
    } catch (e) {
      _addTestResult('Token Availability', false, 'Error checking token: $e');
    }
  }

  Future<void> _testGetAllHotels() async {
    try {
      final hotels = await _hotelService.getAllHotels().timeout(
        const Duration(seconds: 30),
      );
      _addTestResult(
        'Get All Hotels', 
        true, 
        'Successfully retrieved ${hotels.length} hotels'
      );
    } catch (e) {
      String errorMsg = 'Failed to get hotels: ${_getDetailedErrorMessage(e)}';
      _addTestResult('Get All Hotels', false, errorMsg);
    }
  }

  Future<void> _testHotelValidation() async {
    try {
      // Test with hotel ID 1 (common test ID)
      // The validateHotelId method is not available anymore, so just try to get the hotel by ID
      final hotel = await _hotelService.getHotelById(1).timeout(
        const Duration(seconds: 30),
      );
      if (hotel != null) {
        _addTestResult('Hotel Validation', true, 'Hotel ID 1 is valid');
      } else {
        _addTestResult('Hotel Validation', false, 'Hotel ID 1 is not valid or not found');
      }
    } catch (e) {
      String errorMsg = 'Error validating hotel: ${_getDetailedErrorMessage(e)}';
      _addTestResult('Hotel Validation', false, errorMsg);
    }
  }

  Future<void> _testReservationService() async {
    try {
      // Try to get reservations for hotel ID 1
      final List<Reservation> fetchedReservations = await _reservationService.getReservationsByHotelId(1);
      _addTestResult(
        'Reservation Service',
        true,
        'Successfully retrieved \\${fetchedReservations.length} reservations for hotel ID 1',
      );
    } catch (e) {
      _addTestResult('Reservation Service', false, 'Failed to get reservations: \\${_getDetailedErrorMessage(e)}');
    }
  }
  Future<void> _testHotelCreation() async {
    try {
      
      // This is the exact JSON format required by the API
      final hotelData = HotelUtils.generateTestHotelData(); // Owner ID 2 is used for testing

      // Direct API call with exact JSON format
      final response = await _hotelService.authenticatedPost(
        'hotels', 
        body: hotelData,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _addTestResult('Hotel Creation', true, 
          'Hotel created successfully with status code ${response.statusCode}');
      } else {
        _addTestResult('Hotel Creation', false, 
          'API responded with status code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('403') || 
          errorString.contains('forbidden') || 
          errorString.contains('access denied') ||
          errorString.contains('only owners can create')) {
        _addTestResult(
          'Hotel Creation', 
          true, 
          'Endpoint accessible (no creation permission - expected)'
        );
      } else {
        String errorMsg = 'Error testing hotel creation: ${_getDetailedErrorMessage(e)}';
        _addTestResult('Hotel Creation', false, errorMsg);
      }
    }
  }
  Future<void> _testStorageServiceVsDirectStorage() async {
    try {
      // Import the StorageService
      final storageService = StorageService();
      
      // Direct storage access
      String? directToken = await storage.read(key: 'token').timeout(const Duration(seconds: 10));
      bool directTokenExists = directToken != null && directToken.isNotEmpty;
      bool directTokenValid = false;
        if (directTokenExists) {
        try {
          directTokenValid = !JwtDecoder.isExpired(directToken);
        } catch (e) {
          directTokenValid = false;
        }
      }
        // StorageService access
      String? serviceToken = await storageService.getToken().timeout(const Duration(seconds: 10));
      
      // Get headers from StorageService to see if it includes Authorization
      Map<String, String> headers = await storageService.getAuthHeaders().timeout(const Duration(seconds: 10));
      bool serviceIncludesAuth = headers.containsKey('Authorization');
      
      String resultMessage = '';
      bool testPassed = true;
      
      if (directToken != serviceToken) {
        resultMessage = 'MISMATCH: Direct token != Service token';
        testPassed = false;
      } else if (directTokenExists && !serviceIncludesAuth) {
        resultMessage = 'ISSUE: Token exists but StorageService excludes Authorization header. Token might be expired.';
        testPassed = false;
      } else if (!directTokenExists) {
        resultMessage = 'No token found in either method';
        testPassed = false;
      } else if (directTokenValid && serviceIncludesAuth) {
        resultMessage = 'Both methods work correctly - token is valid and headers include auth';
        testPassed = true;
      } else {
        resultMessage = 'Direct token valid: $directTokenValid, Service includes auth: $serviceIncludesAuth';
        testPassed = directTokenValid == serviceIncludesAuth;
      }
      
      _addTestResult('Storage Service vs Direct Storage', testPassed, resultMessage);
    } catch (e) {
      _addTestResult('Storage Service vs Direct Storage', false, 'Error comparing storage methods: $e');
    }
  }

  String _getDetailedErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeoutexception') || errorString.contains('timeout')) {
      return 'Request timed out - check internet connection and server status';
    } else if (errorString.contains('socketexception')) {
      return 'Network error - unable to connect to server';
    } else if (errorString.contains('handshakeexception')) {
      return 'SSL/TLS handshake failed - certificate or security issue';
    } else if (errorString.contains('httpexception')) {
      return 'HTTP error - server returned an error response';
    } else if (errorString.contains('formatexception')) {
      return 'Invalid response format - server may be returning unexpected data';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Unauthorized - token may be expired, please login again';
    } else if (errorString.contains('403') || errorString.contains('forbidden') || errorString.contains('access denied')) {
      return 'Access denied - insufficient permissions for this operation';
    } else if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Endpoint not found - API may have changed';
    } else if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error - API server is experiencing issues';
    } else if (errorString.contains('session expired')) {
      return 'Session expired - please login again';
    } else {
      return ErrorHandler.getErrorMessage(error);
    }
  }

  void _addTestResult(String test, bool success, String message) {
    setState(() {
      testResults.add({
        'test': test,
        'success': success,
        'message': message,
      });
    });
  }

  void _showTestSummary() {
    final passedTests = testResults.where((result) => result['success'] as bool).length;
    final totalTests = testResults.length;
    
    String summaryTitle;
    String summaryMessage;
    
    if (passedTests == totalTests) {
      summaryTitle = '✅ All Tests Passed!';
      summaryMessage = 'API connectivity is working properly ($passedTests/$totalTests tests passed).';
    } else if (passedTests > 0) {
      summaryTitle = '⚠️ Some Tests Failed';
      summaryMessage = 'Some issues were detected ($passedTests/$totalTests tests passed). Check the failed tests for details.';
    } else {
      summaryTitle = '❌ All Tests Failed';
      summaryMessage = 'No tests passed. Check your internet connection and authentication status.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(summaryTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summaryMessage),
              const SizedBox(height: 16),
              if (passedTests < totalTests) ...[
                const Text(
                  'Common Solutions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Check your internet connection'),
                const Text('• Verify you are logged in'),
                const Text('• Try logging out and back in'),
                const Text('• Check if the API server is accessible'),
                const Text('• Contact support if issues persist'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testHotelCreationOnly() async {
    setState(() {
      isRunningTests = true;
      testResults.clear();
    });

    // Add test for internet connectivity first
    await _testInternetConnectivity();

    // Add test for API reachability
    await _testAPIReachability();

    // Run only the hotel creation test
    await _testHotelCreation();

    setState(() {
      isRunningTests = false;
    });
  }
}
