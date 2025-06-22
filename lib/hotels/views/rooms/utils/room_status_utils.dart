import 'package:flutter/material.dart';
import '../../../models/room.dart';

class RoomStatusUtils {
  static IconData getStatusIcon(String status) {
    switch (status) {
      case RoomStatus.available:
        return Icons.check_circle;
      case RoomStatus.occupied:
        return Icons.hotel;
      case RoomStatus.maintenance:
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.red;
      case RoomStatus.maintenance:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
