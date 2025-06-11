import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_suite/reservations/services/hotel_service.dart';
import 'dart:convert';

// Generate mock classes
@GenerateMocks([http.Client, FlutterSecureStorage])
import 'hotel_service_test.mocks.dart';

void main() {
  group('HotelService', () {
    late HotelService hotelService;
    late MockClient mockHttpClient;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockHttpClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
      hotelService = HotelService();
    });

    group('getHotelById', () {
      test('should return hotel data when API call succeeds', () async {
        // Arrange
        const hotelId = 1;
        const hotelData = {
          'id': 1,
          'name': 'Test Hotel',
          'address': '123 Test St',
          'phone': '+1234567890',
          'email': 'test@hotel.com'
        };
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(hotelData),
          200,
        ));

        // Act
        final result = await hotelService.getHotelById(hotelId);

        // Assert
        expect(result, equals(hotelData));
      });

      test('should return null when hotel not found', () async {
        // Arrange
        const hotelId = 999;
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await hotelService.getHotelById(hotelId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        const hotelId = 1;
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        // Act & Assert
        expect(
          () => hotelService.getHotelById(hotelId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAllHotels', () {
      test('should return list of hotels when API call succeeds', () async {
        // Arrange
        const hotelsData = [
          {
            'id': 1,
            'name': 'Test Hotel 1',
            'address': '123 Test St',
            'phone': '+1234567890',
            'email': 'test1@hotel.com'
          },
          {
            'id': 2,
            'name': 'Test Hotel 2',
            'address': '456 Test Ave',
            'phone': '+0987654321',
            'email': 'test2@hotel.com'
          }
        ];
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(hotelsData),
          200,
        ));

        // Act
        final result = await hotelService.getAllHotels();

        // Assert
        expect(result, equals(hotelsData));
        expect(result.length, equals(2));
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        // Act & Assert
        expect(
          () => hotelService.getAllHotels(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getHotelsByOwnerId', () {
      test('should return owner hotels when API call succeeds', () async {
        // Arrange
        const ownerId = 123;
        const ownerHotels = [
          {
            'id': 1,
            'name': 'Owner Hotel 1',
            'address': '123 Owner St',
            'phone': '+1234567890',
            'email': 'owner1@hotel.com',
            'ownerId': 123
          }
        ];
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/owner/$ownerId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(ownerHotels),
          200,
        ));

        // Act
        final result = await hotelService.getHotelsByOwnerId(ownerId);

        // Assert
        expect(result, equals(ownerHotels));
        expect(result.length, equals(1));
      });
    });

    group('validateHotelId', () {
      test('should return true when hotel exists', () async {
        // Arrange
        const hotelId = 1;
        const hotelData = {
          'id': 1,
          'name': 'Test Hotel',
          'address': '123 Test St'
        };
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(hotelData),
          200,
        ));

        // Act
        final result = await hotelService.validateHotelId(hotelId);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when hotel does not exist', () async {
        // Arrange
        const hotelId = 999;
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await hotelService.validateHotelId(hotelId);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when network error occurs', () async {
        // Arrange
        const hotelId = 1;
        
        when(mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'test_token');
        
        when(mockHttpClient.get(
          Uri.parse('https://sweetmanager-api.ryzeon.me/api/v1/hotels/$hotelId'),
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await hotelService.validateHotelId(hotelId);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
