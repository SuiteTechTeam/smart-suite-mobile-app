class CreateRoomDeviceResource {
  // Add properties based on your API definition
  final int roomId;
  final int iotDeviceId;

  CreateRoomDeviceResource({required this.roomId, required this.iotDeviceId});

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'iotDeviceId': iotDeviceId,
  };
}
