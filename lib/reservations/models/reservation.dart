class Reservation {
  final int id;
  final int customerId;
  final int resourceId;
  final String resourceType; // 'restaurant', 'spa', 'conference_room', 'equipment', etc.
  final String title;
  final String description;
  final DateTime reservationDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final int guestCount;
  final double totalAmount;
  final String? specialRequests;
  final int hotelId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.customerId,
    required this.resourceId,
    required this.resourceType,
    required this.title,
    required this.description,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.guestCount,
    required this.totalAmount,
    this.specialRequests,
    required this.hotelId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      resourceId: json['resourceId'] ?? 0,
      resourceType: json['resourceType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      reservationDate: DateTime.parse(json['reservationDate']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'] ?? 'pending',
      guestCount: json['guestCount'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      specialRequests: json['specialRequests'],
      hotelId: json['hotelId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'resourceId': resourceId,
      'resourceType': resourceType,
      'title': title,
      'description': description,
      'reservationDate': reservationDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'guestCount': guestCount,
      'totalAmount': totalAmount,
      'specialRequests': specialRequests,
      'hotelId': hotelId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
