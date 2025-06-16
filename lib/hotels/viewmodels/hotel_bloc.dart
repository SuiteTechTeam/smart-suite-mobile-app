import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';
import '../../iam/services/auth_service.dart';
import '../../iam/services/storage_service.dart';
import 'hotel_event.dart';
import 'hotel_state.dart' as hotel_state;

class HotelBloc extends Bloc<HotelEvent, hotel_state.HotelState> {
  final HotelService hotelService;
  final AuthService authService;
  final StorageService _storageService = StorageService();

  HotelBloc({
    required this.hotelService,
    required this.authService,
  }) : super(hotel_state.HotelInitial()) {
    on<HotelLoadRequested>(_onHotelLoadRequested);
    on<HotelCreateRequested>(_onHotelCreateRequested);
    on<HotelUpdateRequested>(_onHotelUpdateRequested);
    on<HotelDeleteRequested>(_onHotelDeleteRequested);
    on<HotelSelected>(_onHotelSelected);
    on<HotelFilterByOwner>(_onHotelFilterByOwner);
  }

  Future<void> _onHotelLoadRequested(
    HotelLoadRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      emit(hotel_state.HotelLoading());      // Get user information from token using AuthService, which has the correct claim fields
      String? userRole = await authService.getUserRole();
      int? userId = await authService.getUserId();

      // Load hotels based on user role
      List<Hotel> hotels;
      if (userRole?.toLowerCase() == 'owner' && userId != null) {
        hotels = await hotelService.getHotelsByOwnerId(userId);
      } else {
        hotels = await hotelService.getAllHotels();
      }

      emit(hotel_state.HotelLoaded(
        hotels: hotels,
        userRole: userRole,
        userId: userId,
      ));
    } catch (e) {
      emit(hotel_state.HotelError('Failed to load hotels: ${e.toString()}'));
    }
  }  Future<void> _onHotelCreateRequested(
    HotelCreateRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      emit(hotel_state.HotelLoading());

      if (event.hotelData['name'] == null || event.hotelData['name'].isEmpty) {
        emit(hotel_state.HotelError('Hotel name cannot be empty.'));
        return;
      }

      // The HotelService now handles all authentication and authorization checks
      // No need to pass ownerId as it will use the authenticated user's ID
      await hotelService.createHotel(
        name: event.hotelData['name'],
        address: event.hotelData['address'],
        phone: event.hotelData['phone'],
        email: event.hotelData['email'],
        description: event.hotelData['description'],
        // ownerId is no longer passed - service uses authenticated user's ID
      );

      // Reload hotels to get the updated list
      add(HotelLoadRequested());
      
      emit(hotel_state.HotelOperationSuccess(
        message: 'Hotel created successfully',
        hotels: [], // Will be updated by the reload
      ));
    } catch (e) {
      emit(hotel_state.HotelError('Failed to create hotel: ${e.toString()}'));
    }
  }  Future<void> _onHotelUpdateRequested(
    HotelUpdateRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      emit(hotel_state.HotelLoading());

      // The HotelService now handles all authentication and authorization checks
      // No need to pass ownerId as it will use the authenticated user's ID
      await hotelService.updateHotel(
        hotelId: event.hotelId,
        name: event.hotelData['name'],
        address: event.hotelData['address'],
        phone: event.hotelData['phone'],
        email: event.hotelData['email'],
        description: event.hotelData['description'],
        // ownerId is no longer passed - service uses authenticated user's ID
      );

      // Reload hotels to get the updated list
      add(HotelLoadRequested());

      emit(hotel_state.HotelOperationSuccess(
        message: 'Hotel updated successfully',
        hotels: [], // Will be updated by the reload
      ));
    } catch (e) {
      emit(hotel_state.HotelError('Failed to update hotel: ${e.toString()}'));
    }
  }  Future<void> _onHotelDeleteRequested(
    HotelDeleteRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      emit(hotel_state.HotelLoading());

      // The HotelService now handles all authentication and authorization checks
      // Only authenticated owners can delete their own hotels
      final success = await hotelService.deleteHotel(event.hotelId);
      
      if (success) {
        // Reload hotels to get the updated list
        add(HotelLoadRequested());
        
        emit(hotel_state.HotelOperationSuccess(
          message: 'Hotel deleted successfully',
          hotels: [], // Will be updated by the reload
        ));
      } else {
        emit(hotel_state.HotelError('Failed to delete hotel'));
      }
    } catch (e) {
      emit(hotel_state.HotelError('Failed to delete hotel: ${e.toString()}'));
    }
  }Future<void> _onHotelSelected(
    HotelSelected event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      await _storageService.write(key: 'selected_hotel_id', value: event.hotelId.toString());
      
      emit(hotel_state.HotelSelectionState(
        hotelId: event.hotelId,
        message: 'Hotel selected: ID ${event.hotelId}',
      ));
    } catch (e) {
      emit(hotel_state.HotelError('Failed to select hotel: ${e.toString()}'));
    }
  }

  Future<void> _onHotelFilterByOwner(
    HotelFilterByOwner event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      emit(hotel_state.HotelLoading());

      final hotels = await hotelService.getHotelsByOwnerId(event.ownerId);

      final currentState = state;
      String? userRole;
      int? userId;

      if (currentState is hotel_state.HotelLoaded) {
        userRole = currentState.userRole;
        userId = currentState.userId;
      }

      emit(hotel_state.HotelLoaded(
        hotels: hotels,
        userRole: userRole,
        userId: userId,
      ));
    } catch (e) {
      emit(hotel_state.HotelError('Failed to filter hotels by owner: ${e.toString()}'));
    }
  }
}
