import 'dart:convert';
import '../models/type_room.dart';
import '../../core/services/base_service.dart';

class TypeRoomService extends BaseService {
  TypeRoomService({super.httpClient});

  Future<List<TypeRoom>> getAllTypeRooms(int hotelId) async {
    final response = await authenticatedGet('type-room/get-all-type-rooms?hotelid=$hotelId');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TypeRoom.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load type rooms');
    }
  }

  /// Handles both JSON and plain string success responses from backend
  Future<TypeRoom?> createTypeRoom({required int hotelId, required String description, required double price}) async {
    final response = await authenticatedPost(
      'type-room/create-type-room',
      body: {
        'hotelId': hotelId,
        'description': description,
        'price': price,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return TypeRoom.fromJson(decoded);
        } else {
          // Si el backend devuelve un string, tratar como éxito pero sin objeto devuelto
          return null;
        }
      } catch (e) {
        // Si no es JSON, tratar como mensaje de éxito simple
        return null;
      }
    } else {
      throw Exception('Failed to create type room: ${response.body}');
    }
  }
}
