import 'package:flutter/material.dart';
import '../models/available_room.dart';
import '../models/reservation.dart';
import '../models/reservation_resource.dart';
import 'payment_customer_service.dart';
import 'reservation_service.dart';
import '../../hotels/services/room_service.dart';
import '../../hotels/services/type_room_service.dart';
import '../../hotels/models/room.dart';
import '../../hotels/models/type_room.dart';
import '../../iam/services/guest_service.dart';

class BookingFlowService {
  final PaymentCustomerService _paymentCustomerService;
  final ReservationService _reservationService;
  final RoomService _roomService;
  final TypeRoomService _typeRoomService;
  final GuestService _guestService;

  BookingFlowService({
    PaymentCustomerService? paymentCustomerService,
    ReservationService? reservationService,
    RoomService? roomService,
    TypeRoomService? typeRoomService,
    GuestService? guestService,
  }) : 
    _paymentCustomerService = paymentCustomerService ?? PaymentCustomerService(),
    _reservationService = reservationService ?? ReservationService(),
    _roomService = roomService ?? RoomService(),
    _typeRoomService = typeRoomService ?? TypeRoomService(),
    _guestService = guestService ?? GuestService();

  // Get available rooms with type information
  Future<List<AvailableRoom>> getAvailableRooms({
    required DateTime startDate,
    required DateTime finalDate,
    required int hotelId,
  }) async {
    try {
      debugPrint('Debug - getAvailableRooms: Getting rooms for hotel $hotelId');
      debugPrint('Debug - getAvailableRooms: Date range: $startDate to $finalDate');

      // Get available rooms from API
      List<Room> availableRooms = await _roomService.getAvailableRoomsForBooking(
        startDate: startDate,
        finalDate: finalDate,
        hotelId: hotelId,
      );

      debugPrint('Debug - getAvailableRooms: Found ${availableRooms.length} available rooms');

      // Get all type rooms for the hotel to enrich room data
      List<TypeRoom> typeRooms = await _typeRoomService.getAllTypeRooms(hotelId);
      debugPrint('Debug - getAvailableRooms: Found ${typeRooms.length} type rooms');
      
      // Create a map for quick lookup
      Map<int, TypeRoom> typeRoomMap = {
        for (var typeRoom in typeRooms) typeRoom.id: typeRoom
      };

      // Combine room and type room data
      List<AvailableRoom> availableRoomsWithInfo = availableRooms.map((room) {
        TypeRoom? typeRoom = typeRoomMap[room.typeRoomId];
        if (typeRoom == null) {
          debugPrint('Debug - getAvailableRooms: No type room found for room ${room.id} with typeRoomId ${room.typeRoomId}');
        }
        return AvailableRoom.fromRoomAndType(room, typeRoom);
      }).toList();

      debugPrint('Debug - getAvailableRooms: Returning ${availableRoomsWithInfo.length} enriched rooms');
      return availableRoomsWithInfo;
    } catch (e) {
      debugPrint('Debug - getAvailableRooms Error: $e');
      rethrow;
    }
  }

  // Create a complete booking flow with improved error handling
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
      debugPrint('Debug - createBooking: Starting booking creation');
      debugPrint('Debug - createBooking: Guest ID: $guestId, Room ID: $roomId');
      debugPrint('Debug - createBooking: Date range: $startDate to $finalDate');
      debugPrint('Debug - createBooking: Price per night: $pricePerNight');

      // Validate dates first
      validateBookingDates(startDate, finalDate);

      // Validate other parameters
      if (guestId <= 0) {
        throw Exception('ID de huésped inválido: $guestId');
      }
      if (roomId <= 0) {
        throw Exception('ID de habitación inválido: $roomId');
      }
      if (description.trim().isEmpty) {
        throw Exception('La descripción no puede estar vacía');
      }
      if (pricePerNight <= 0) {
        throw Exception('El precio por noche debe ser mayor a 0');
      }

      // Step 1: Verify guest exists
      debugPrint('Debug - createBooking: Verifying guest exists...');
      final guest = await _guestService.getGuestById(guestId);
      if (guest == null) {
        throw Exception('El huésped con ID $guestId no existe');
      }
      debugPrint('Debug - createBooking: Guest verified: ${guest.fullName}');

      // Step 2: Get or create payment customer
      debugPrint('Debug - createBooking: Getting or creating payment customer...');
      PaymentCustomer paymentCustomer = await _paymentCustomerService.getOrCreatePaymentCustomer(
        guestId,
        initialAmount: 0.0,
      );
      debugPrint('Debug - createBooking: Payment customer ID: ${paymentCustomer.id}');

      if (paymentCustomer.id == null) {
        throw Exception('No se pudo crear o obtener el cliente de pago');
      }

      // Step 3: Calculate booking details
      int nightCount = finalDate.difference(startDate).inDays;
      if (nightCount <= 0) nightCount = 1; // Minimum 1 night
      
      double totalAmount = pricePerNight * nightCount;
      debugPrint('Debug - createBooking: Calculated $nightCount nights, total amount: $totalAmount');

      // Step 4: Create the reservation
      Reservation reservation = Reservation(
        paymentCustomerId: paymentCustomer.id!,
        roomId: roomId,
        description: description.trim(),
        startDate: startDate,
        finalDate: finalDate,
        priceRoom: pricePerNight,
        nightCount: nightCount,
        amount: totalAmount,
        state: 'CONFIRMED',
        preferenceId: preferenceId,
      );

      debugPrint('Debug - createBooking: Created reservation object');
      debugPrint('Debug - createBooking: Reservation data: ${reservation.toJson()}');

      // Step 5: Save reservation to API and get the created reservation
      debugPrint('Debug - createBooking: Creating reservation in API...');
      Reservation createdReservation = await _reservationService.createReservationAndReturn(reservation);
      debugPrint('Debug - createBooking: Reservation created successfully with ID: ${createdReservation.id}');

      // Step 6: Update payment customer with final amount
      debugPrint('Debug - createBooking: Updating payment customer with final amount...');
      PaymentCustomer updatedPaymentCustomer = PaymentCustomer(
        guestId: paymentCustomer.guestId,
        finalAmount: totalAmount,
      );
      
      await _paymentCustomerService.updatePaymentCustomer(
        paymentCustomer.id!,
        updatedPaymentCustomer,
      );
      debugPrint('Debug - createBooking: Payment customer updated successfully');

      debugPrint('Debug - createBooking: Booking creation completed successfully');
      return createdReservation;
    } catch (e) {
      debugPrint('Debug - createBooking Error: $e');
      if (e.toString().contains('type List<dynamic> is not a subtype of type Map<String, dynamic>')) {
        debugPrint('Debug - createBooking: Detected List/Map type mismatch error');
        throw Exception('Error al procesar la respuesta del servidor. Por favor, inténtelo de nuevo.');
      }
      rethrow;
    }
  }

  // Create a booking with resource reservation (restaurant, spa, etc.)
  Future<ReservationResource> createResourceBooking({
    required int guestId,
    required int resourceId,
    required String description,
    required DateTime startDate,
    required DateTime finalDate,
    required double pricePerHour,
    int preferenceId = 0,
  }) async {
    try {
      debugPrint('Debug - createResourceBooking: Starting resource booking creation');
      debugPrint('Debug - createResourceBooking: Guest ID: $guestId, Resource ID: $resourceId');

      // Validate dates
      validateBookingDates(startDate, finalDate);

      // Verify guest exists
      final guest = await _guestService.getGuestById(guestId);
      if (guest == null) {
        throw Exception('El huésped con ID $guestId no existe');
      }

      // Get or create payment customer
      PaymentCustomer paymentCustomer = await _paymentCustomerService.getOrCreatePaymentCustomer(
        guestId,
        initialAmount: 0.0,
      );

      // Calculate booking details
      int hourCount = finalDate.difference(startDate).inHours;
      if (hourCount <= 0) hourCount = 1; // Minimum 1 hour
      
      double totalAmount = pricePerHour * hourCount;

      // Crear la reservación como Reservation (no ReservationResource)
      Reservation reservation = Reservation(
        paymentCustomerId: paymentCustomer.id!,
        roomId: resourceId,
        description: description,
        startDate: startDate,
        finalDate: finalDate,
        priceRoom: pricePerHour,
        nightCount: hourCount,
        amount: totalAmount,
        state: 'CONFIRMED',
        preferenceId: preferenceId,
      );

      // Save to API (using the same booking endpoint)
      Reservation createdReservation = await _reservationService.createReservationAndReturn(reservation);

      // Update payment customer
      PaymentCustomer updatedPaymentCustomer = PaymentCustomer(
        guestId: paymentCustomer.guestId,
        finalAmount: totalAmount,
      );
      
      await _paymentCustomerService.updatePaymentCustomer(
        paymentCustomer.id!,
        updatedPaymentCustomer,
      );

      // Convert Reservation to ReservationResource for return
      return ReservationResource(
        id: createdReservation.id,
        paymentCustomerId: createdReservation.paymentCustomerId,
        roomId: createdReservation.roomId,
        description: createdReservation.description,
        startDate: createdReservation.startDate,
        finalDate: createdReservation.finalDate,
        priceRoom: createdReservation.priceRoom,
        nightCount: createdReservation.nightCount,
        amount: createdReservation.amount,
        state: createdReservation.state,
        preferenceId: createdReservation.preferenceId,
      );
    } catch (e) {
      debugPrint('Debug - createResourceBooking Error: $e');
      rethrow;
    }
  }

  // Create a minimal booking for testing
  Future<Reservation> createMinimalBooking({
    required int guestId,
    required int roomId,
    required DateTime startDate,
    required DateTime finalDate,
  }) async {
    try {
      debugPrint('Debug - createMinimalBooking: Creating minimal booking for testing');
      
      // Validate dates
      validateBookingDates(startDate, finalDate);

      // Get or create payment customer
      PaymentCustomer paymentCustomer = await _paymentCustomerService.getOrCreatePaymentCustomer(
        guestId,
        initialAmount: 0.0,
      );

      if (paymentCustomer.id == null) {
        throw Exception('No se pudo crear o obtener el cliente de pago');
      }

      // Create minimal reservation
      Reservation reservation = Reservation(
        paymentCustomerId: paymentCustomer.id!,
        roomId: roomId,
        description: 'Reservación de prueba',
        startDate: startDate,
        finalDate: finalDate,
        priceRoom: 100.0, // Default price
        nightCount: finalDate.difference(startDate).inDays,
        amount: 100.0 * finalDate.difference(startDate).inDays,
        state: 'CONFIRMED',
        preferenceId: 0,
      );

      debugPrint('Debug - createMinimalBooking: Minimal reservation data: ${reservation.toJson()}');
      
      return await _reservationService.createReservationAndReturn(reservation);
    } catch (e) {
      debugPrint('Debug - createMinimalBooking Error: $e');
      rethrow;
    }
  }

  // Validate booking dates with improved error messages
  bool validateBookingDates(DateTime startDate, DateTime finalDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (startDate.isBefore(today)) {
      throw Exception('La fecha de inicio no puede ser en el pasado. Por favor seleccione una fecha futura.');
    }
    
    if (finalDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser después de la fecha de inicio.');
    }
    
    if (finalDate.isAtSameMomentAs(startDate)) {
      throw Exception('La fecha final debe ser diferente a la fecha de inicio.');
    }

    // Check if booking is too far in the future (optional validation)
    final maxBookingDate = today.add(const Duration(days: 365)); // 1 year ahead
    if (finalDate.isAfter(maxBookingDate)) {
      throw Exception('No se pueden hacer reservaciones con más de un año de anticipación.');
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

  // Calculate total amount for a resource booking
  double calculateResourceTotalAmount({
    required double pricePerHour,
    required DateTime startDate,
    required DateTime finalDate,
  }) {
    int hourCount = finalDate.difference(startDate).inHours;
    if (hourCount <= 0) hourCount = 1;
    return pricePerHour * hourCount;
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

  // Get resource booking summary
  Map<String, dynamic> getResourceBookingSummary({
    required String resourceName,
    required double pricePerHour,
    required DateTime startDate,
    required DateTime finalDate,
  }) {
    int hourCount = finalDate.difference(startDate).inHours;
    if (hourCount <= 0) hourCount = 1;
    
    double totalAmount = pricePerHour * hourCount;
    
    return {
      'resourceName': resourceName,
      'pricePerHour': pricePerHour,
      'hourCount': hourCount,
      'totalAmount': totalAmount,
      'startDate': startDate,
      'finalDate': finalDate,
    };
  }

  // Check if a room is available for the given dates
  Future<bool> isRoomAvailable({
    required int roomId,
    required DateTime startDate,
    required DateTime finalDate,
    required int hotelId,
  }) async {
    try {
      List<AvailableRoom> availableRooms = await getAvailableRooms(
        startDate: startDate,
        finalDate: finalDate,
        hotelId: hotelId,
      );

      return availableRooms.any((room) => room.room.id == roomId);
    } catch (e) {
      debugPrint('Debug - isRoomAvailable Error: $e');
      return false;
    }
  }

  // Get booking statistics for a hotel
  Future<Map<String, dynamic>> getBookingStatistics(int hotelId) async {
    try {
      List<Reservation> allReservations = await _reservationService.getReservationsByHotelId(hotelId);
      
      int totalReservations = allReservations.length;
      int pendingReservations = allReservations.where((r) => r.state == 'pending').length;
      int confirmedReservations = allReservations.where((r) => r.state == 'confirmed').length;
      int cancelledReservations = allReservations.where((r) => r.state == 'cancelled').length;
      
      double totalRevenue = allReservations.fold(0.0, (sum, r) => sum + r.amount);
      
      return {
        'totalReservations': totalReservations,
        'pendingReservations': pendingReservations,
        'confirmedReservations': confirmedReservations,
        'cancelledReservations': cancelledReservations,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      debugPrint('Debug - getBookingStatistics Error: $e');
      rethrow;
    }
  }
} 