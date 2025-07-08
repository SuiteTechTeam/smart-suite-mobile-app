import 'dart:convert';
import '../models/room.dart';
import '../../core/services/base_service.dart';

class RoomService extends BaseService {
  RoomService({super.httpClient});

  // Create a new room
  Future<Room> createRoom(Room room) async {
    // await HotelAuthValidator.validateOwnerAccess(); // Ensure user is an owner

    final response = await authenticatedPost(
      'room/create-room', // Updated Endpoint for creating rooms
      body: room.toCreateJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create room: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Get all rooms for a specific hotel
  Future<List<Room>> getRoomsByHotelId(int hotelId) async {
    // Potentially add access validation here if needed
    // await HotelAuthValidator.validateHotelAccess(hotelId);

    final response = await authenticatedGet(
      'room/get-all-rooms?hotelId=$hotelId',
    ); // Updated Endpoint

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load rooms for hotel $hotelId: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Get a specific room by its ID
  Future<Room?> getRoomById(int roomId) async {
    final response = await authenticatedGet(
      'room/get-room-by-id?id=$roomId',
    ); // Updated Endpoint

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData.isEmpty) {
        return null; // Or handle as appropriate if API returns empty for not found
      }
      return Room.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      return null; // Room not found
    } else {
      throw Exception(
        'Failed to load room $roomId: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Update an existing room's state
  Future<Room> updateRoomState(int roomId, String newState) async {
    // await HotelAuthValidator.validateOwnerAccess();
    // Add validation to ensure the user owns the hotel this room belongs to

    final Map<String, dynamic> body = {
      'roomId':
          roomId, // This field name is an assumption for UpdateRoomStateResource
      'state': newState,
    };

    final response = await authenticatedPut(
      'room/update-room-state', // Updated Endpoint for updating a room's state
      body: body,
    );

    if (response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update room state for $roomId: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Delete a room
  Future<void> deleteRoom(int roomId) async {
    // await HotelAuthValidator.validateOwnerAccess();
    // Add validation to ensure the user owns the hotel this room belongs to

    final response = await authenticatedDelete('rooms/$roomId');

    if (response.statusCode != 204 && response.statusCode != 200) {
      // 204 No Content is also a success
      throw Exception(
        'Failed to delete room $roomId: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Get available rooms for booking based on date range and hotel
  Future<List<Room>> getAvailableRoomsForBooking({
    required DateTime startDate,
    required DateTime finalDate,
    required int hotelId,
  }) async {
    try {
      final response = await authenticatedGet(
        'room/get-room-by-booking-availability?'
        'startDate=${startDate.toIso8601String()}&'
        'finalDate=${finalDate.toIso8601String()}&'
        'hotelId=$hotelId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get available rooms: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get rooms by state
  Future<List<Room>> getRoomsByState(String state) async {
    try {
      final response = await authenticatedGet(
        'room/get-room-by-state?state=$state',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get rooms by state: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get rooms by type room
  Future<List<Room>> getRoomsByTypeRoom(int typeRoomId) async {
    try {
      final response = await authenticatedGet(
        'room/get-room-by-type-room?typeRoomId=$typeRoomId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get rooms by type room: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
