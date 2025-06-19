import 'package:flutter/material.dart';
import '../../../models/hotel.dart';
import '../utils/hotel_detail_utils.dart';

class HotelDetailContactCard extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailContactCard({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            HotelDetailUtils.buildInfoRow(
              Icons.location_on,
              'Address',
              hotel.address,
            ),
            const SizedBox(height: 8),
            HotelDetailUtils.buildInfoRow(Icons.phone, 'Phone', hotel.phone),
            const SizedBox(height: 8),
            HotelDetailUtils.buildInfoRow(Icons.email, 'Email', hotel.email),
          ],
        ),
      ),
    );
  }
}
