import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../utils/room_status_utils.dart';

class RoomListItem extends StatelessWidget {
  final Room room;

  const RoomListItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: Icon(
          RoomStatusUtils.getStatusIcon(room.state),
          color: RoomStatusUtils.getStatusColor(room.state),
        ),
        title: Text(
          'Habitación ID: ${room.id} - Tipo: ${room.typeRoomId}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${room.state}'),
            Text('Hotel ID: ${room.hotelId}'),
          ],
        ),
      ),
    );
  }
}
