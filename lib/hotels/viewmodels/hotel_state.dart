import 'package:equatable/equatable.dart';
import '../models/hotel.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
  final String? userRole;
  final int? userId;

  const HotelLoaded({
    required this.hotels,
    this.userRole,
    this.userId,
  });

  @override
  List<Object?> get props => [hotels, userRole, userId];

  HotelLoaded copyWith({
    List<Hotel>? hotels,
    String? userRole,
    int? userId,
  }) {
    return HotelLoaded(
      hotels: hotels ?? this.hotels,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
    );
  }
}

class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}

class HotelOperationSuccess extends HotelState {
  final String message;
  final List<Hotel> hotels;

  const HotelOperationSuccess({
    required this.message,
    required this.hotels,
  });

  @override
  List<Object?> get props => [message, hotels];
}

class HotelSelectionState extends HotelState {
  final int hotelId;
  final String message;

  const HotelSelectionState({
    required this.hotelId,
    required this.message,
  });

  @override
  List<Object?> get props => [hotelId, message];
}
