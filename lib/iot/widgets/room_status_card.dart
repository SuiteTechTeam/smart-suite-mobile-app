import 'package:flutter/material.dart';
import '../models/room_summary.dart';

class RoomStatusCard extends StatelessWidget {
  final RoomSummary room;
  final VoidCallback onTap;
  final bool isSelected;
  
  const RoomStatusCard({
    super.key,
    required this.room,
    required this.onTap,
    this.isSelected = false,
  });  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: isSelected ? 3 : 1,
      color: isDarkMode 
          ? (isSelected ? Colors.blue.shade900 : Colors.grey[850])
          : (isSelected ? Colors.blue.shade50 : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
              ? Colors.blue.shade300 
              : (isDarkMode ? Colors.grey.shade700 : Colors.transparent),
          width: isSelected ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: room.status.color.withOpacity(0.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(room.status),
                          size: 16,
                          color: room.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: room.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),              const SizedBox(height: 8),
              Text(
                'Piso ${room.floor}', 
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey
                )
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${room.currentTemperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getStatusIcon(RoomOccupancyStatus status) {
    switch (status) {
      case RoomOccupancyStatus.ocupada:
        return Icons.person;
      case RoomOccupancyStatus.libre:
        return Icons.check_circle;
      case RoomOccupancyStatus.mantenimiento:
        return Icons.handyman;
    }
  }
}
