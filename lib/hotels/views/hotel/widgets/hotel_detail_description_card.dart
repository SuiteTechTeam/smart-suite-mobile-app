import 'package:flutter/material.dart';
import '../../../models/hotel.dart';

class HotelDetailDescriptionCard extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailDescriptionCard({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    if (hotel.description == null || hotel.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hotel.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
