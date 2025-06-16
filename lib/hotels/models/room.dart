class Room {
  final int id;
  final int typeRoomId;
  final int hotelId;
  final String state;

  Room({
    required this.id,
    required this.typeRoomId,
    required this.hotelId,
    required this.state,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      typeRoomId: json['typeRoomId'] ?? 0,
      hotelId: json['hotelId'] ?? 0,
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeRoomId': typeRoomId,
      'hotelId': hotelId,
      'state': state,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'typeRoomId': typeRoomId, 'hotelId': hotelId, 'state': state};
  }
}

class RoomStatus {
  static const String available = 'available';
  static const String occupied = 'occupied';
  static const String maintenance = 'maintenance';
}
