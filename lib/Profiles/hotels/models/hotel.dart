class Hotel {
  final int? id;
  final String? name;
  final String? address;
  final int? phoneNumber;
  final String? description;
  final String? email;
  final int? ownerId;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.description,
    required this.ownerId
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      ownerId: json['ownersId'] as int,
      description: json['description'] as String,
      phoneNumber: json['phone'] as int,
      email: json['email'] as String
    );
  }
}