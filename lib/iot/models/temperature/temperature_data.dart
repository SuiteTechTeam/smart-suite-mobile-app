class TemperatureData {
  final int roomId;
  final double value;
  final DateTime timestamp;

  TemperatureData({
    required this.roomId,
    required this.value,
    required this.timestamp,
  });

  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      roomId: json['roomId'] ?? 0,
      value: (json['value'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}
