class Hotel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? description;
  final int? ownerId;
  final double? rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.description,
    this.ownerId,
    this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      description: json['description'],
      ownerId: json['ownerId'],
      rating: json['rating']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
      'ownerId': ownerId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
      'ownerId': ownerId,
    };
  }

  Hotel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    int? ownerId,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Hotel(id: $id, name: $name, address: $address, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hotel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
