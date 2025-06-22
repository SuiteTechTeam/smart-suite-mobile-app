import 'package:flutter/material.dart';
import '../../../models/hotel.dart';
import '../../../services/hotel_service.dart';
import './hotel_detail_header_card.dart';
import './hotel_detail_contact_card.dart';
import './hotel_detail_description_card.dart';
import './hotel_detail_info_card.dart';

class HotelDetailView extends StatelessWidget {
  final int hotelId;

  const HotelDetailView({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Hotel?>(
        future: HotelService().getHotelById(hotelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading hotel details',
                    style: TextStyle(fontSize: 18, color: Colors.red[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final hotel = snapshot.data;
          if (hotel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Hotel not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HotelDetailHeaderCard(hotel: hotel),
                const SizedBox(height: 16),
                HotelDetailContactCard(hotel: hotel),
                const SizedBox(height: 16),
                HotelDetailDescriptionCard(hotel: hotel),
                const SizedBox(height: 16),
                HotelDetailInfoCard(hotel: hotel),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
