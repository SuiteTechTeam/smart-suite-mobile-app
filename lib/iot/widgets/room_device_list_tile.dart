import 'package:flutter/material.dart';
import '../models/room_device/room_device.dart';

class RoomDeviceListTile extends StatelessWidget {
  final RoomDevice roomDevice;
  const RoomDeviceListTile({super.key, required this.roomDevice});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Room ID: ${roomDevice.roomId}'),
      subtitle: Text('IoT Device ID: ${roomDevice.iotDeviceId}'),
    );
  }
}
