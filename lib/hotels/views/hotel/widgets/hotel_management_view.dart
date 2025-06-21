import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/hotel.dart';
import '../../../viewmodels/hotel_bloc.dart';
import '../../../viewmodels/hotel_event.dart';
import '../../../viewmodels/hotel_state.dart' as hotel_state;
import '../../../utils/hotel_auth_validator.dart';
import 'hotel_card_item.dart';
import 'hotel_dialog.dart';

class HotelManagementView extends StatelessWidget {
  const HotelManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HotelBloc, hotel_state.HotelState>(
        listener: (context, state) {
          if (state is hotel_state.HotelOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is hotel_state.HotelError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<HotelBloc, hotel_state.HotelState>(
          builder: (context, state) {
            if (state is hotel_state.HotelLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is hotel_state.HotelError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HotelBloc>().add(HotelLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is hotel_state.HotelLoaded) {
              if (state.hotels.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<HotelBloc>().add(HotelLoadRequested());
                        },
                        child: const Text('Refresh'),
                      ),
                      const Icon(
                        Icons.hotel_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hotels found',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.hotels.length,
                itemBuilder: (context, index) {
                  final hotel = state.hotels[index];
                  return HotelCardItem(
                    hotel: hotel, 
                    userRole: state.userRole, 
                    onSelect: _selectHotel, 
                    onUpdate: _showUpdateHotelDialog,
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: HotelAuthValidator.isCurrentUserOwner(),
        builder: (context, snapshot) {
          debugPrint(
            '[HotelScreen] FAB Builder - isOwner: ${snapshot.data}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}',
          );
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton.extended(
              onPressed: () => _showCreateHotelDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Hotel'),
              backgroundColor: Theme.of(context).primaryColor,
            );
          }
          return const SizedBox.shrink(); // No FAB for non-owner users
        },
      ),
    );
  }

  void _selectHotel(BuildContext context, int hotelId) {
    context.read<HotelBloc>().add(HotelSelected(hotelId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Hotel selected: ID $hotelId')));
    Navigator.pop(context, true);
  }

  void _showCreateHotelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => HotelDialog(
        existingHotel: null,
        onSave: (hotelData) {
          context.read<HotelBloc>().add(HotelCreateRequested(hotelData));
        },
      ),
    );
  }

  void _showUpdateHotelDialog(BuildContext context, Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => HotelDialog(
        existingHotel: hotel,
        onSave: (hotelData) {
          context.read<HotelBloc>().add(
            HotelUpdateRequested(hotel.id, hotelData),
          );
        },
      ),
    );
  }
}
