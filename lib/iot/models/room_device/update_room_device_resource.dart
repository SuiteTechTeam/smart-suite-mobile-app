class UpdateRoomDeviceResource {
  // Add properties based on your API definition
  final int? roomId;
  final int? iotDeviceId;

  UpdateRoomDeviceResource({this.roomId, this.iotDeviceId});

  Map<String, dynamic> toJson() => {
    if (roomId != null) 'roomId': roomId,
    if (iotDeviceId != null) 'iotDeviceId': iotDeviceId,
  };
}
