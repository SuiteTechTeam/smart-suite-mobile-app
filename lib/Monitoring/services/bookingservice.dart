import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sweetmanager/Monitoring/models/booking.dart';

import '../models/customerr.dart';

class BookingService {

  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/bookings/';

  final storage = const FlutterSecureStorage();

  Future<bool> createBooking(Booking booking, Customerr customer) async {

    final token = await storage.read(key: 'token');

    var response = await http.post(
      Uri.parse('https://sweetmanager-api.ryzeon.me/api/customer/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'id': customer.id,
        'username': customer.username,
        'name': customer.name,
        'surname': customer.surname,
        'email': customer.email,
        'phone': customer.phone,
        'state': customer.state
      }),
    );

    response = await http.post(
      Uri.parse('https://sweetmanager-api.ryzeon.me/create-payment-customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'customerId': customer.id,
        'finalAmount': booking.priceRoom * booking.nightCount
      }),
    );

    final paymentJson = await http.get(
        Uri.parse('https://sweetmanager-api.ryzeon.me/get-payments-customer-id?customerId=${customer.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    List<dynamic> payments = json.decode(paymentJson.body);

    var maxId = payments.map((payment) => payment['id']).reduce((a, b) => a > b ? a : b);

    response = await http.post(
      Uri.parse('${baseUrl}create-booking'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'paymentCustomerId': maxId,
        'roomId': booking.roomId,
        'description': booking.description,
        'startDate': booking.startDate.toIso8601String(),
        'finalDate': booking.finalDate.toIso8601String(),
        'priceRoom': booking.priceRoom,
        'nightCount': booking.nightCount
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<bool> updateBooking(String id, Booking booking) async {

    final token = await storage.read(key: 'token');

    final response = await http.put(
      Uri.parse('${baseUrl}update-booking-state'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'id': booking.id,
        'bookingState': booking.bookingState
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<Booking>> getBookingsByHotelId(String hotelId) async {

    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('${baseUrl}get-all-bookings/$hotelId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      List<dynamic> data = json.decode(response.body);
      return data.map((bookingJson) => Booking(
        id: bookingJson['id'],
        paymentCustomerId: bookingJson['paymentCustomerId'],
        roomId: bookingJson['roomId'],
        description: bookingJson['description'],
        startDate: DateTime.parse(bookingJson['startDate']),
        finalDate: DateTime.parse(bookingJson['finalDate']),
        priceRoom: bookingJson['priceRoom'],
        nightCount: bookingJson['nightCount'],
        amount: bookingJson['amount'],
        bookingState: bookingJson['bookingState'],
      )).toList();
    } else {

      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Booking> getBookingById(String id) async {

    final token = await storage.read(key: 'token');

    if (id == 0) {
      throw Exception('The booking id cannot be 0.');
    }

    final response = await http.get(
      Uri.parse('${baseUrl}get-booking-id?id=$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var bookingJson = json.decode(response.body);
      return Booking(
        id: bookingJson['id'],
        paymentCustomerId: bookingJson['paymentCustomerId'],
        roomId: bookingJson['roomId'],
        description: bookingJson['description'],
        startDate: DateTime.parse(bookingJson['startDate']),
        finalDate: DateTime.parse(bookingJson['finalDate']),
        priceRoom: bookingJson['priceRoom'],
        nightCount: bookingJson['nightCount'],
        amount: bookingJson['amount'],
        bookingState: bookingJson['bookingState'],
      );
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}