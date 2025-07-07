import 'package:flutter/material.dart';
import '../models/room_device/room_device.dart';

class RoomDeviceListTile extends StatelessWidget {
  final RoomDevice roomDevice;
  final VoidCallback? onTap;

  const RoomDeviceListTile({
    super.key,
    required this.roomDevice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue.withValues(alpha: 0.2),
          child: Icon(
            Icons.devices,
            color: Colors.lightBlue,
          ),
        ),
        title: Text(
          'Dispositivo #${roomDevice.id}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IoT Device: ${roomDevice.iotDeviceId}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              'Habitación: ${roomDevice.roomId}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: onTap,
      ),
    );
  }
}
