import 'package:flutter/material.dart';

class ReservationResource {
  final int? id;
  final int? paymentCustomerId;
  final int? roomId;
  final String? description;
  final DateTime? startDate;
  final DateTime? finalDate;
  final double? priceRoom;
  final int? nightCount;
  final double? amount;
  final String? state;
  final int? preferenceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationResource({
    this.id,
    this.paymentCustomerId,
    this.roomId,
    this.description,
    this.startDate,
    this.finalDate,
    this.priceRoom,
    this.nightCount,
    this.amount,
    this.state,
    this.preferenceId,
    this.createdAt,
    this.updatedAt,
  });

  // Utility function to format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  factory ReservationResource.fromJson(Map<String, dynamic> json) {
    try {
      return ReservationResource(
        id: json['id'],
        paymentCustomerId: json['paymentCustomerId'],
        roomId: json['roomId'],
        description: json['description'],
        startDate: json['startDate'] != null 
            ? DateTime.parse(json['startDate'].toString())
            : null,
        finalDate: json['finalDate'] != null 
            ? DateTime.parse(json['finalDate'].toString())
            : null,
        priceRoom: json['priceRoom'] != null 
            ? (json['priceRoom'] is int 
                ? (json['priceRoom'] as int).toDouble() 
                : json['priceRoom'].toDouble())
            : null,
        nightCount: json['nightCount'],
        amount: json['amount'] != null 
            ? (json['amount'] is int 
                ? (json['amount'] as int).toDouble() 
                : json['amount'].toDouble())
            : null,
        state: json['state'] ?? 'CONFIRMED',
        preferenceId: json['preferenceId'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Debug - ReservationResource.fromJson parsing error: $e');
      debugPrint('Debug - JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (paymentCustomerId != null) json['paymentCustomerId'] = paymentCustomerId;
    if (roomId != null) json['roomId'] = roomId;
    if (description != null) json['description'] = description;
    if (startDate != null) json['startDate'] = _formatDate(startDate!);
    if (finalDate != null) json['finalDate'] = _formatDate(finalDate!);
    if (priceRoom != null) json['priceRoom'] = priceRoom;
    if (nightCount != null) json['nightCount'] = nightCount;
    if (amount != null) json['amount'] = amount;
    if (state != null) json['state'] = state;
    if (preferenceId != null) json['preferenceId'] = preferenceId;

    // Only include id if it exists (for updates)
    if (id != null) {
      json['id'] = id!;
    }

    return json;
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'paymentCustomerId': paymentCustomerId,
      'roomId': roomId,
      'description': description ?? '',
      'startDate': startDate != null ? _formatDate(startDate!) : null,
      'finalDate': finalDate != null ? _formatDate(finalDate!) : null,
      'priceRoom': priceRoom ?? 0.0,
      'nightCount': nightCount ?? 1,
      'amount': amount ?? 0.0,
      'state': state ?? 'CONFIRMED',
      'preferenceId': preferenceId ?? 0,
    };
  }

  ReservationResource copyWith({
    int? id,
    int? paymentCustomerId,
    int? roomId,
    String? description,
    DateTime? startDate,
    DateTime? finalDate,
    double? priceRoom,
    int? nightCount,
    double? amount,
    String? state,
    int? preferenceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationResource(
      id: id ?? this.id,
      paymentCustomerId: paymentCustomerId ?? this.paymentCustomerId,
      roomId: roomId ?? this.roomId,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      finalDate: finalDate ?? this.finalDate,
      priceRoom: priceRoom ?? this.priceRoom,
      nightCount: nightCount ?? this.nightCount,
      amount: amount ?? this.amount,
      state: state ?? this.state,
      preferenceId: preferenceId ?? this.preferenceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
