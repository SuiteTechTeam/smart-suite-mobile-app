class NotificationHistory {
  final int id;
  final int roomDeviceId;
  final String message;
  final DateTime createdAt;
  // Add other properties as needed

  NotificationHistory({required this.id, required this.roomDeviceId, required this.message, required this.createdAt});

  factory NotificationHistory.fromJson(Map<String, dynamic> json) {
    return NotificationHistory(
      id: json['id'],
      roomDeviceId: json['roomDeviceId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
