import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweetmanager/Monitoring/models/typeroom.dart';
import 'package:http/http.dart' as http;

class TypeRoomService {

  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/types-rooms/';

  final storage = const FlutterSecureStorage();

  Future<List<TypeRoom>> getTypesRooms(String hotelId) async {

    final token = await storage.read(key: 'token');

    final response = await http.get(
        Uri.parse('${baseUrl}get-all-type-rooms?hotelId=$hotelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      // Convertimos los datos en una lista de TypeRoom
      List<TypeRoom> typeRooms = data.map((roomJson) => TypeRoom(
        id: roomJson['id'],
        name: roomJson['description'],
      )).toList();

      List<TypeRoom> newList = [];

      List<int>ids = [];

      var validation = false;

      for (int i = 0; i < typeRooms.length; ++i) {

        if (i + 1 < typeRooms.length && typeRooms[i].id != typeRooms[i+1].id)
        {
          ids.add(typeRooms[i].id);

          newList.add(typeRooms[i]);
        }
        if(i + 1 == typeRooms.length)
        {
          for(int j = 0; j < ids.length; j++)
          {
            if(typeRooms[i].id == ids[j])
            {
              validation = true;
            }
          }
        }
      }

      if(!validation)
      {
        newList.add(typeRooms[typeRooms.length -  1]);
      }

      return newList;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}