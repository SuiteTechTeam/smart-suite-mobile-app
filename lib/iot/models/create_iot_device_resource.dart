class CreateIoTDeviceResource {
  // Add properties based on your API definition
  final String name;
  final String type;

  CreateIoTDeviceResource({required this.name, required this.type});

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
  };
}
