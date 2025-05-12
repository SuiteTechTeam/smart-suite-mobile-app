import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/room.dart';

class RoomService {

  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/rooms/';

  final storage = const FlutterSecureStorage();

  Future<bool> createRoom(Room room) async {

    final token = await storage.read(key: 'token');

    if (room.typeRoomId == 0 || room.hotelId == 0 || room.roomState.isEmpty) {

      throw Exception('All fields are required.');
    }

    final response = await http.post(

      Uri.parse('${baseUrl}create-room'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'typeRoomId': room.typeRoomId,
        'hotelId': room.hotelId,
        'roomState': room.roomState,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<bool> updateRoom(String id, Room room) async {

    final token = await storage.read(key: 'token');

    final response = await http.post(

      Uri.parse('${baseUrl}update-room-state'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'id': id,
        'roomState': room.roomState,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<Room>> getRooms(String hotelId) async {

    final token = await storage.read(key: 'token');

    final response = await http.get(
        Uri.parse('${baseUrl}get-all-rooms?hotelId=$hotelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((roomJson) => Room(
        id: roomJson['id'],
        typeRoomId: roomJson['typeRoomId'],
        hotelId: roomJson['hotelId'],
        roomState: roomJson['roomState']
      )).toList();

    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Room> getRoomById(String id) async {

    final token = await storage.read(key: 'token');

    if (id == 0) {

      throw Exception('The room id cannot be 0.');
    }

    final response = await http.get(
        Uri.parse('${baseUrl}get-room-by-id?id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      var roomJson = json.decode(response.body);

      return Room(
          id: roomJson['id'],
          typeRoomId: roomJson['typeRoomId'],
          hotelId: roomJson['hotelId'],
          roomState: roomJson['roomState']
      );
    }
    else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}