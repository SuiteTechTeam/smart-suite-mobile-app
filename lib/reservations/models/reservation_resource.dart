class ReservationResource {
  final int id;
  final String name;
  final String type; // 'restaurant', 'spa', 'conference_room', 'equipment', etc.
  final String description;
  final int capacity;
  final double pricePerHour;
  final String status; // 'available', 'maintenance', 'reserved'
  final int hotelId;
  final Map<String, dynamic>? amenities;
  final String? location;
  final String? imageUrl;

  ReservationResource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
    required this.pricePerHour,
    required this.status,
    required this.hotelId,
    this.amenities,
    this.location,
    this.imageUrl,
  });

  factory ReservationResource.fromJson(Map<String, dynamic> json) {
    return ReservationResource(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'available',
      hotelId: json['hotelId'] ?? 0,
      amenities: json['amenities'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'capacity': capacity,
      'pricePerHour': pricePerHour,
      'status': status,
      'hotelId': hotelId,
      'amenities': amenities,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
