class IoTDevice {
  final int id;
  final String name;

  IoTDevice({required this.id, required this.name});

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'],
      name: json['name'],
    );
  }
}
