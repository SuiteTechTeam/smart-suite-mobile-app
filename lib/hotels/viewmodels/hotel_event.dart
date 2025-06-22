import 'package:equatable/equatable.dart';

abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

class HotelLoadRequested extends HotelEvent {}

class HotelCreateRequested extends HotelEvent {
  final Map<String, dynamic> hotelData;

  const HotelCreateRequested(this.hotelData);

  @override
  List<Object?> get props => [hotelData];
}

class HotelUpdateRequested extends HotelEvent {
  final int hotelId;
  final Map<String, dynamic> hotelData;

  const HotelUpdateRequested(this.hotelId, this.hotelData);

  @override
  List<Object?> get props => [hotelId, hotelData];
}

class HotelDeleteRequested extends HotelEvent {
  final int hotelId;

  const HotelDeleteRequested(this.hotelId);

  @override
  List<Object?> get props => [hotelId];
}

class HotelSelected extends HotelEvent {
  final int hotelId;

  const HotelSelected(this.hotelId);

  @override
  List<Object?> get props => [hotelId];
}

class HotelFilterByOwner extends HotelEvent {
  final int ownerId;

  const HotelFilterByOwner(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}
