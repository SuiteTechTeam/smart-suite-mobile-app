import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/hotel_service.dart';
import '../services/reservation_service.dart';
import '../utils/error_handler.dart';

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
      appBar: AppBar(
        title: const Text('API Connectivity Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
                    const SizedBox(height: 16),
                    SizedBox(
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
                            : const Text('Run API Tests'),
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
              Expanded(
                child: ListView.builder(
                  itemCount: testResults.length,
                  itemBuilder: (context, index) {
                    final result = testResults[index];
                    final isSuccess = result['success'] as bool;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                        title: Text(result['test'] as String),
                        subtitle: Text(result['message'] as String),
                        trailing: Text(
                          isSuccess ? 'PASS' : 'FAIL',
                          style: TextStyle(
                            color: isSuccess ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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

    // Test 1: Check if we have a valid token
    await _testTokenAvailability();

    // Test 2: Test hotel service - get all hotels
    await _testGetAllHotels();

    // Test 3: Test hotel validation with a known hotel ID
    await _testHotelValidation();

    // Test 4: Test reservation service
    await _testReservationService();

    // Test 5: Test hotel creation (if user is owner)
    await _testHotelCreation();

    setState(() {
      isRunningTests = false;
    });

    _showTestSummary();
  }

  Future<void> _testTokenAvailability() async {
    try {
      String? token = await storage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        _addTestResult('Token Availability', true, 'Authentication token found');
      } else {
        _addTestResult('Token Availability', false, 'No authentication token found');
      }
    } catch (e) {
      _addTestResult('Token Availability', false, 'Error checking token: $e');
    }
  }

  Future<void> _testGetAllHotels() async {
    try {
      final hotels = await _hotelService.getAllHotels();
      _addTestResult(
        'Get All Hotels', 
        true, 
        'Successfully retrieved ${hotels.length} hotels'
      );
    } catch (e) {
      _addTestResult(
        'Get All Hotels', 
        false, 
        'Failed to get hotels: ${ErrorHandler.getErrorMessage(e)}'
      );
    }
  }

  Future<void> _testHotelValidation() async {
    try {
      // Test with hotel ID 1 (common test ID)
      final isValid = await _hotelService.validateHotelId(1);
      if (isValid) {
        _addTestResult('Hotel Validation', true, 'Hotel ID 1 is valid');
      } else {
        _addTestResult('Hotel Validation', false, 'Hotel ID 1 is not valid or not found');
      }
    } catch (e) {
      _addTestResult(
        'Hotel Validation', 
        false, 
        'Error validating hotel: ${ErrorHandler.getErrorMessage(e)}'
      );
    }
  }

  Future<void> _testReservationService() async {
    try {
      // Try to get reservations for hotel ID 1
      final reservations = await _reservationService.getReservationsByHotelId(1);
      _addTestResult(
        'Reservation Service', 
        true, 
        'Successfully retrieved ${reservations.length} reservations for hotel ID 1'
      );
    } catch (e) {
      _addTestResult(
        'Reservation Service', 
        false, 
        'Failed to get reservations: ${ErrorHandler.getErrorMessage(e)}'
      );
    }
  }

  Future<void> _testHotelCreation() async {
    try {
      // This is a test that will likely fail due to permissions, but tests the endpoint
      await _hotelService.createHotel(
        name: 'Test Hotel',
        address: 'Test Address',
        phone: '+1234567890',
        email: 'test@test.com',
      );
      _addTestResult('Hotel Creation', true, 'Hotel creation endpoint is accessible');
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('403') || errorMessage.contains('forbidden')) {
        _addTestResult(
          'Hotel Creation', 
          true, 
          'Endpoint accessible (no creation permission - expected)'
        );
      } else {
        _addTestResult(
          'Hotel Creation', 
          false, 
          'Error testing hotel creation: ${ErrorHandler.getErrorMessage(e)}'
        );
      }
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
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Passed: $passedTests/$totalTests tests'),
              const SizedBox(height: 8),
              if (passedTests == totalTests)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('All tests passed!'),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Some tests failed.'),
                  ],
                ),
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
}
