class IoTDevice {
  final int id;
  final String name;
  final String type;
  // Add other properties as needed

  IoTDevice({required this.id, required this.name, required this.type});

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}
