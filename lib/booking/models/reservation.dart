import 'package:flutter/material.dart';
class Reservation {
  // NOTE: In Smart Suite, 'booking' and 'reservation' are the same concept.
  // This model is used for both creating and displaying bookings/reservations.

  final int? id;
  final int paymentCustomerId;
  final int roomId;
  final String description;
  final DateTime startDate;
  final DateTime finalDate;
  final double priceRoom;
  final int nightCount;
  final double amount;
  final String state;
  final int preferenceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    this.id,
    required this.paymentCustomerId,
    required this.roomId,
    required this.description,
    required this.startDate,
    required this.finalDate,
    required this.priceRoom,
    required this.nightCount,
    required this.amount,
    required this.state,
    required this.preferenceId,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    try {
      return Reservation(
        id: json['id'],
        paymentCustomerId: json['paymentCustomerId'] ?? 0,
        roomId: json['roomId'] ?? 0,
        description: json['description'] ?? '',
        startDate: json['startDate'] != null 
            ? DateTime.parse(json['startDate'].toString())
            : DateTime.now(),
        finalDate: json['finalDate'] != null 
            ? DateTime.parse(json['finalDate'].toString())
            : DateTime.now().add(const Duration(days: 1)),
        priceRoom: (json['priceRoom'] ?? 0.0).toDouble(),
        nightCount: json['nightCount'] ?? 0,
        amount: (json['amount'] ?? 0.0).toDouble(),
        state: json['state'] ?? 'pending',
        preferenceId: json['preferenceId'] ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Debug - Reservation.fromJson parsing error: $e');
      debugPrint('Debug - JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'paymentCustomerId': paymentCustomerId,
      'roomId': roomId,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'finalDate': finalDate.toIso8601String(),
      'priceRoom': priceRoom,
      'nightCount': nightCount,
      'amount': amount,
      'state': state,
      'preferenceId': preferenceId,
    };

    // Only include id if it exists (for updates)
    if (id != null) {
      json['id'] = id!;
    }

    return json;
  }
}
