import 'package:flutter/material.dart';
import '../models/available_room.dart';
import '../models/reservation.dart';
import 'payment_customer_service.dart';
import 'reservation_service.dart';
import '../../hotels/services/room_service.dart';
import '../../hotels/services/type_room_service.dart';
import '../../hotels/models/room.dart';
import '../../hotels/models/type_room.dart';

class BookingFlowService {
  final PaymentCustomerService _paymentCustomerService;
  final ReservationService _reservationService;
  final RoomService _roomService;
  final TypeRoomService _typeRoomService;

  BookingFlowService({
    PaymentCustomerService? paymentCustomerService,
    ReservationService? reservationService,
    RoomService? roomService,
    TypeRoomService? typeRoomService,
  }) : 
    _paymentCustomerService = paymentCustomerService ?? PaymentCustomerService(),
    _reservationService = reservationService ?? ReservationService(),
    _roomService = roomService ?? RoomService(),
    _typeRoomService = typeRoomService ?? TypeRoomService();

  // Get available rooms with type information
  Future<List<AvailableRoom>> getAvailableRooms({
    required DateTime startDate,
    required DateTime finalDate,
    required int hotelId,
  }) async {
    try {
      // Get available rooms from API
      List<Room> availableRooms = await _roomService.getAvailableRoomsForBooking(
        startDate: startDate,
        finalDate: finalDate,
        hotelId: hotelId,
      );

      // Get all type rooms for the hotel to enrich room data
      List<TypeRoom> typeRooms = await _typeRoomService.getAllTypeRooms(hotelId);
      
      // Create a map for quick lookup
      Map<int, TypeRoom> typeRoomMap = {
        for (var typeRoom in typeRooms) typeRoom.id: typeRoom
      };

      // Combine room and type room data
      List<AvailableRoom> availableRoomsWithInfo = availableRooms.map((room) {
        TypeRoom? typeRoom = typeRoomMap[room.typeRoomId];
        return AvailableRoom.fromRoomAndType(room, typeRoom);
      }).toList();

      return availableRoomsWithInfo;
    } catch (e) {
      rethrow;
    }
  }

  // Create a complete booking flow
  Future<Reservation> createBooking({
    required int guestId,
    required int roomId,
    required String description,
    required DateTime startDate,
    required DateTime finalDate,
    required double pricePerNight,
    int preferenceId = 0,
  }) async {
    try {
      // Step 1: Get or create payment customer
      PaymentCustomer paymentCustomer = await _paymentCustomerService.getOrCreatePaymentCustomer(
        guestId,
        initialAmount: 0.0,
      );

      // Step 2: Calculate booking details
      int nightCount = finalDate.difference(startDate).inDays;
      if (nightCount <= 0) nightCount = 1; // Minimum 1 night
      
      double totalAmount = pricePerNight * nightCount;

      // Step 3: Create the reservation
      Reservation reservation = Reservation(
        paymentCustomerId: paymentCustomer.id!,
        roomId: roomId,
        description: description,
        startDate: startDate,
        finalDate: finalDate,
        priceRoom: pricePerNight,
        nightCount: nightCount,
        amount: totalAmount,
        state: 'pending',
        preferenceId: preferenceId,
      );

      // Step 4: Save reservation to API and get the created reservation
      debugPrint('Debug - createBooking: Creating reservation...');
      Reservation createdReservation = await _reservationService.createReservationAndReturn(reservation);
      debugPrint('Debug - createBooking: Reservation created successfully');

      // Step 5: Update payment customer with final amount
      debugPrint('Debug - createBooking: Updating payment customer...');
      PaymentCustomer updatedPaymentCustomer = PaymentCustomer(
        guestId: paymentCustomer.guestId,
        finalAmount: totalAmount,
      );
      
      await _paymentCustomerService.updatePaymentCustomer(
        paymentCustomer.id!,
        updatedPaymentCustomer,
      );
      debugPrint('Debug - createBooking: Payment customer updated successfully');

      return createdReservation;
    } catch (e) {
      debugPrint('Debug - createBooking Error: $e');
      if (e.toString().contains('type List<dynamic> is not a subtype of type Map<String, dynamic>')) {
        debugPrint('Debug - createBooking: Detected List/Map type mismatch error');
        // If we can't parse the response, throw a more specific error
        throw Exception('Error al procesar la respuesta del servidor. Por favor, inténtelo de nuevo.');
      }
      rethrow;
    }
  }

  // Validate booking dates
  bool validateBookingDates(DateTime startDate, DateTime finalDate) {
    if (startDate.isBefore(DateTime.now())) {
      throw Exception('La fecha de inicio no puede ser en el pasado');
    }
    
    if (finalDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser después de la fecha de inicio');
    }
    
    if (finalDate.isAtSameMomentAs(startDate)) {
      throw Exception('La fecha final debe ser diferente a la fecha de inicio');
    }

    return true;
  }

  // Calculate total amount for a booking
  double calculateTotalAmount({
    required double pricePerNight,
    required DateTime startDate,
    required DateTime finalDate,
  }) {
    int nightCount = finalDate.difference(startDate).inDays;
    if (nightCount <= 0) nightCount = 1;
    return pricePerNight * nightCount;
  }

  // Get booking summary
  Map<String, dynamic> getBookingSummary({
    required AvailableRoom selectedRoom,
    required DateTime startDate,
    required DateTime finalDate,
  }) {
    int nightCount = finalDate.difference(startDate).inDays;
    if (nightCount <= 0) nightCount = 1;
    
    double totalAmount = selectedRoom.pricePerNight * nightCount;
    
    return {
      'roomName': selectedRoom.displayName,
      'pricePerNight': selectedRoom.pricePerNight,
      'nightCount': nightCount,
      'totalAmount': totalAmount,
      'startDate': startDate,
      'finalDate': finalDate,
    };
  }
} 