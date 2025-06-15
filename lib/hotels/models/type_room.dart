class TypeRoom {
  final int id;
  final String description;
  final double price;

  TypeRoom({
    required this.id,
    required this.description,
    required this.price,
  });

  factory TypeRoom.fromJson(Map<String, dynamic> json) {
    return TypeRoom(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'price': price,
    };
  }
}
