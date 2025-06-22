import 'package:flutter/material.dart';
import '../../../models/hotel.dart';

class HotelSelectionItem extends StatelessWidget {
  final Hotel hotel;
  final Function(int) onSelect;

  const HotelSelectionItem({
    super.key,
    required this.hotel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.hotel, color: Colors.white, size: 20),
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
          onPressed: () => onSelect(hotel.id),
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
