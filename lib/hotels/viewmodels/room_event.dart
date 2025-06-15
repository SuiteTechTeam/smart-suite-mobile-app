import 'package:equatable/equatable.dart';
import '../models/room.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final int hotelId;

  const LoadRooms(this.hotelId);

  @override
  List<Object?> get props => [hotelId];
}

class AddRoom extends RoomEvent {
  final Room room;

  const AddRoom(this.room);

  @override
  List<Object?> get props => [room];
}

class UpdateRoomState extends RoomEvent {
  final int roomId;
  final String newState;

  const UpdateRoomState(this.roomId, this.newState);

  @override
  List<Object?> get props => [roomId, newState];
}

class DeleteRoom extends RoomEvent {
  final int roomId;

  const DeleteRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LoadRoomById extends RoomEvent {
  final int roomId;

  const LoadRoomById(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
