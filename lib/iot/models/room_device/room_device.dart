class RoomDevice {
  final int id;
  final int roomId;
  final int iotDeviceId;
  // Add other properties as needed

  RoomDevice({required this.id, required this.roomId, required this.iotDeviceId});

  factory RoomDevice.fromJson(Map<String, dynamic> json) {
    return RoomDevice(
      id: json['id'],
      roomId: json['roomId'],
      iotDeviceId: json['iotDeviceId'],
    );
  }
}
