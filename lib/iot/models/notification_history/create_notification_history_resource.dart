class CreateNotificationHistoryResource {
  // Add properties based on your API definition
  final int roomDeviceId;
  final String message;

  CreateNotificationHistoryResource({required this.roomDeviceId, required this.message});

  Map<String, dynamic> toJson() => {
    'roomDeviceId': roomDeviceId,
    'message': message,
  };
}
