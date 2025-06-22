class CreateIoTDeviceResource {
  // Add properties based on your API definition
  final String name;
  
  CreateIoTDeviceResource({required this.name});

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}
