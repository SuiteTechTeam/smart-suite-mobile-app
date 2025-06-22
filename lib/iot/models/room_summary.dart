import 'package:flutter/material.dart';
import 'package:smart_suite/hotels/models/room.dart';

enum RoomOccupancyStatus {
  ocupada,
  libre,
  mantenimiento
}

extension RoomOccupancyStatusExtension on RoomOccupancyStatus {
  String get label {
    switch (this) {
      case RoomOccupancyStatus.ocupada:
        return 'Ocupada';
      case RoomOccupancyStatus.libre:
        return 'Libre';
      case RoomOccupancyStatus.mantenimiento:
        return 'Mantenimiento';
    }
  }

  Color get color {
    switch (this) {
      case RoomOccupancyStatus.ocupada:
        return Colors.green;
      case RoomOccupancyStatus.libre:
        return Colors.blue;
      case RoomOccupancyStatus.mantenimiento:
        return Colors.orange;
    }
  }
}

RoomOccupancyStatus getRoomOccupancyStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'occupied':
    case 'ocupada':
      return RoomOccupancyStatus.ocupada;
    case 'available':
    case 'libre':
      return RoomOccupancyStatus.libre;
    case 'maintenance':
    case 'mantenimiento':
      return RoomOccupancyStatus.mantenimiento;
    default:
      return RoomOccupancyStatus.libre;
  }
}

class RoomSummary {
  final int id;
  final int number;
  final String name;
  final int floor;
  final RoomOccupancyStatus status;
  final double currentTemperature;
  
  RoomSummary({
    required this.id,
    this.number = 0,
    required this.name,
    required this.floor,
    required this.status,
    this.currentTemperature = 23.0,
  });
  
  factory RoomSummary.fromRoom(Room room) {
    // Extract room number from name if possible (like "Habitación 101" -> 101)
    int roomNumber = 0;
    final nameRegExp = RegExp(r'(\d+)$');
    final match = nameRegExp.firstMatch(room.id.toString());
    if (match != null) {
      roomNumber = int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    
    // Extract floor number if possible (first digit of room number)
    int floor = 1;
    if (roomNumber >= 100) {
      floor = roomNumber ~/ 100;
    }
    
    return RoomSummary(
      id: room.id,
      number: roomNumber,
      name: 'Habitación ${room.id}',
      floor: floor,
      status: getRoomOccupancyStatusFromString(room.state),
      currentTemperature: 22 + (room.id % 5),  // Mock temperature between 22-26°C
    );
  }
}
