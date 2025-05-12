import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/services/roomservice.dart';
import 'package:sweetmanager/Monitoring/services/typeroomservice.dart';

import '../models/typeroom.dart';

class AddRoomDialog extends StatefulWidget {
  const AddRoomDialog({super.key});

  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {

  // Services

  final storage = const FlutterSecureStorage();

  late RoomService roomService = RoomService();
  
  late TypeRoomService typeRoomService = TypeRoomService();
  
  // Attributes basic

  final List<dynamic> roomStates = [
    {'id': 1, 'name': 'OCUPADO'},
    {'id': 2, 'name': 'LIBRE'}
  ];

  String? selectedTypeRoomId;
  
  List<TypeRoom> typeRooms = [];
  
  bool isLoading = true;

  String? selectedStatusId = 1.toString();

  late Future<String?> fHotelId;
  
  late String? hotelId;

  @override
  void initState() {
    super.initState();

    fetchTypeRooms();

    _getHotelId().then((hotelIdValue) {
      setState(() {
        hotelId = hotelIdValue;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add new room"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedTypeRoomId,
            onChanged: (value) {
              setState(() {
                selectedTypeRoomId = value;
              });
            },
            items: typeRooms.map((room) {
              return DropdownMenuItem<String>(
                value: room.id.toString(),
                child: Text(room.name),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Type Room ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedStatusId,
            onChanged: (value) {
              setState(() {
                selectedStatusId = value;
              });
            },
            items: roomStates.map((room) {
              return DropdownMenuItem<String>(
                value: room['id'].toString(),
                child: Text(room['name']),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Type Room ID',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text("Accept"),
          onPressed: () async {

            final int newTypeRoomId = int.parse(selectedTypeRoomId!);

            final int newHotelId = int.tryParse(hotelId ?? '') ?? 0;

            await roomService.createRoom(
              Room(
                id: 0,
                typeRoomId: newTypeRoomId,
                hotelId: newHotelId,
                roomState: int.parse(selectedStatusId!) == 1? 'OCUPADO': 'LIBRE',
              ),
            );

            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  Future<void> fetchTypeRooms() async {
    try {
      final rooms = await typeRoomService
          .getTypesRooms(await _getHotelId() as String);
      setState(() {
        typeRooms = rooms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar los tipos de habitaciones: $e');
    }
  }

  Future<String?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();
  }

}
