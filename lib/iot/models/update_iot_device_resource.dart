class UpdateIoTDeviceResource {
  // Add properties based on your API definition
  final String? name;
  final String? type;

  UpdateIoTDeviceResource({this.name, this.type});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (type != null) 'type': type,
  };
}
