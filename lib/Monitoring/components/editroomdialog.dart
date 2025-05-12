import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/services/roomservice.dart';

class EditRoomDialog extends StatefulWidget {

  final int id;
  final int typeRoomId;
  final int hotelId;
  final String roomState;

  const EditRoomDialog({
    super.key,
    required this.id,
    required this.typeRoomId,
    required this.hotelId,
    required this.roomState,
  });

  @override
  _EditRoomDialogState createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {

  late RoomService roomService = RoomService();
  late TextEditingController id;
  late TextEditingController roomState;

  @override
  void initState() {
    super.initState();
    id = TextEditingController(text: widget.id.toString());
    roomState = TextEditingController(text: widget.roomState);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update room state"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: id,
            decoration: const InputDecoration(labelText: 'ID'),
            readOnly: true,
          ),
          TextFormField(
            controller: roomState,
            decoration: const InputDecoration(labelText: 'Room State'),
            keyboardType: TextInputType.text,
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

            final String updatedRoomState = roomState.text;

            await roomService.updateRoom(widget.id.toString(),
                Room(id: widget.id, typeRoomId: 0, hotelId: 0,
                    roomState: updatedRoomState)
            );

            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    id.dispose();
    roomState.dispose();
    super.dispose();
  }
}