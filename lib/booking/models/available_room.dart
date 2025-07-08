import '../../hotels/models/room.dart';
import '../../hotels/models/type_room.dart';

class AvailableRoom {
  final Room room;
  final TypeRoom? typeRoom;
  final double pricePerNight;
  final bool isAvailable;
  final String? availabilityMessage;

  AvailableRoom({
    required this.room,
    this.typeRoom,
    required this.pricePerNight,
    required this.isAvailable,
    this.availabilityMessage,
  });

  factory AvailableRoom.fromRoomAndType(Room room, TypeRoom? typeRoom) {
    return AvailableRoom(
      room: room,
      typeRoom: typeRoom,
      pricePerNight: typeRoom?.price ?? 0.0,
      isAvailable: room.state == RoomStatus.available,
      availabilityMessage: room.state == RoomStatus.available 
          ? 'Disponible' 
          : 'No disponible',
    );
  }

  factory AvailableRoom.fromJson(Map<String, dynamic> json) {
    return AvailableRoom(
      room: Room.fromJson(json['room'] ?? {}),
      typeRoom: json['typeRoom'] != null 
          ? TypeRoom.fromJson(json['typeRoom']) 
          : null,
      pricePerNight: (json['pricePerNight'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? false,
      availabilityMessage: json['availabilityMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room.toJson(),
      'typeRoom': typeRoom?.toJson(),
      'pricePerNight': pricePerNight,
      'isAvailable': isAvailable,
      'availabilityMessage': availabilityMessage,
    };
  }

  String get displayName {
    if (typeRoom != null) {
      return '${typeRoom!.description} - Habitación ${room.id}';
    }
    return 'Habitación ${room.id}';
  }

  String get priceDisplay {
    return '\$${pricePerNight.toStringAsFixed(2)} por noche';
  }
} 