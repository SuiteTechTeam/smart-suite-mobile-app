import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';
import '../viewmodels/hotel_bloc.dart';
import '../viewmodels/hotel_event.dart';
import '../viewmodels/hotel_state.dart' as hotel_state;
import '../../iam/services/auth_service.dart';

class HotelSelectionScreen extends StatelessWidget {
  const HotelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelBloc(hotelService: HotelService(), authService: AuthService())
            ..add(HotelLoadRequested()),
      child: const HotelSelectionView(),
    );
  }
}

class HotelSelectionView extends StatelessWidget {
  const HotelSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Hotel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<HotelBloc, hotel_state.HotelState>(
        listener: (context, state) {
          if (state is hotel_state.HotelSelectionState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true);
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
                      style: TextStyle(color: Colors.red[600]),
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hotels available',
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
                  return _buildHotelCard(context, hotel);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.hotel, color: Colors.white, size: 20),
        ),
        title: Text(
          hotel.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hotel.address, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'ID: ${hotel.id}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (hotel.rating != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                  const SizedBox(width: 2),
                  Text(
                    hotel.rating!.toStringAsFixed(1),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<HotelBloc>().add(HotelSelected(hotel.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(60, 32),
          ),
          child: const Text('Select', style: TextStyle(fontSize: 12)),
        ),
        isThreeLine: true,
      ),
    );
  }
}
