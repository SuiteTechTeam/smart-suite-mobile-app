import 'package:flutter/material.dart';
import 'package:smart_suite/hotels/views/rooms/room_management_screen.dart';
import '../../../models/hotel.dart';

class HotelCardItem extends StatelessWidget {
  final Hotel hotel;
  final String? userRole;
  final Function(BuildContext, int) onSelect;
  final Function(BuildContext, Hotel) onUpdate;

  const HotelCardItem({
    super.key,
    required this.hotel,
    required this.userRole,
    required this.onSelect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to reservation management screen with hotelId
        Navigator.pushNamed(
          context,
          '/reservations',
          arguments: {'hotelId': hotel.id},
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hotel,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${hotel.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on, hotel.address),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, hotel.phone),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, hotel.email),
              if (hotel.description != null &&
                  hotel.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.description, hotel.description!),
              ],
              if (hotel.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 6),
                    Text(
                      '${hotel.rating!.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (userRole?.toLowerCase() == 'owner')
                    TextButton.icon(
                      onPressed: () => onUpdate(context, hotel),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    )
                  else
                    const SizedBox.shrink(),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoomManagementScreen(hotelId: hotel.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.meeting_room, size: 16),
                    label: const Text('Rooms'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
