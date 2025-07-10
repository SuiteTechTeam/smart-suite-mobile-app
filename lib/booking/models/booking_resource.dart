import 'package:flutter/material.dart';

class BookingResource {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingResource({
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
    this.createdAt,
    this.updatedAt,
  });

  factory BookingResource.fromJson(Map<String, dynamic> json) {
    try {
      return BookingResource(
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
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Debug - BookingResource.fromJson parsing error: $e');
      debugPrint('Debug - JSON data: $json');
      rethrow;
    }
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
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

  String get displayName => '$name ($type)';
  String get displayPrice => '\$${pricePerHour.toStringAsFixed(2)}/hora';
  String get displayCapacity => '$capacity personas';

  bool get isAvailable => status == 'available';
  bool get isMaintenance => status == 'maintenance';
  bool get isReserved => status == 'reserved';

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'spa':
        return Icons.spa;
      case 'conference_room':
        return Icons.meeting_room;
      case 'equipment':
        return Icons.build;
      case 'gym':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'parking':
        return Icons.local_parking;
      default:
        return Icons.place;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'reserved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  BookingResource copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? capacity,
    double? pricePerHour,
    String? status,
    int? hotelId,
    Map<String, dynamic>? amenities,
    String? location,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingResource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      status: status ?? this.status,
      hotelId: hotelId ?? this.hotelId,
      amenities: amenities ?? this.amenities,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 