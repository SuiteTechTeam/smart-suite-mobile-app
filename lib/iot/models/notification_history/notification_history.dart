class NotificationHistory {
  final int id;
  final int roomDeviceId;
  final String metric;
  final DateTime registrationDate;
  // Add other properties as needed

  NotificationHistory({required this.id, required this.roomDeviceId, required this.metric, required this.registrationDate});

  factory NotificationHistory.fromJson(Map<String, dynamic> json) {
    return NotificationHistory(
      id: json['id'],
      roomDeviceId: json['roomDeviceId'],
      metric: json['metric'],
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }
}
