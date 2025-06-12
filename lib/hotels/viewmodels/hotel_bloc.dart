import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
      emit(hotel_state.HotelLoading());      // Get user information from token
      String? token = await _storageService.getToken();
      String? userRole;
      int? userId;

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userRole = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
        userId = int.tryParse(decodedToken['sub'] ?? '');
      }

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
  }
  Future<void> _onHotelCreateRequested(
    HotelCreateRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is hotel_state.HotelLoaded) {
        // Check if user has owner role before allowing hotel creation
        if (currentState.userRole?.toLowerCase() != 'owner') {
          emit(hotel_state.HotelError('Access denied. Only owners can create hotels.'));
          return;
        }

        emit(hotel_state.HotelLoading());

        await hotelService.createHotel(
          name: event.hotelData['name'],
          address: event.hotelData['address'],
          phone: event.hotelData['phone'],
          email: event.hotelData['email'],
          description: event.hotelData['description'],
          ownerId: currentState.userId,
        );

        // Reload hotels to get the updated list
        add(HotelLoadRequested());
        
        emit(hotel_state.HotelOperationSuccess(
          message: 'Hotel created successfully',
          hotels: currentState.hotels,
        ));
      }
    } catch (e) {
      emit(hotel_state.HotelError('Failed to create hotel: ${e.toString()}'));
    }
  }
  Future<void> _onHotelUpdateRequested(
    HotelUpdateRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is hotel_state.HotelLoaded) {
        // Check if user has owner role before allowing hotel update
        if (currentState.userRole?.toLowerCase() != 'owner') {
          emit(hotel_state.HotelError('Access denied. Only owners can update hotels.'));
          return;
        }

        emit(hotel_state.HotelLoading());

        await hotelService.updateHotel(
          hotelId: event.hotelId,
          name: event.hotelData['name'],
          address: event.hotelData['address'],
          phone: event.hotelData['phone'],
          email: event.hotelData['email'],
          description: event.hotelData['description'],
          ownerId: currentState.userId,
        );

        // Reload hotels to get the updated list
        add(HotelLoadRequested());

        emit(hotel_state.HotelOperationSuccess(
          message: 'Hotel updated successfully',
          hotels: currentState.hotels,
        ));
      }
    } catch (e) {
      emit(hotel_state.HotelError('Failed to update hotel: ${e.toString()}'));
    }
  }
  Future<void> _onHotelDeleteRequested(
    HotelDeleteRequested event,
    Emitter<hotel_state.HotelState> emit,
  ) async {
    emit(hotel_state.HotelError('Delete hotel is not supported by the backend.'));
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
