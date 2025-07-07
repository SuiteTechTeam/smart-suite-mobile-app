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
  });
  
  @override
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
          // Using ConstrainedBox to limit the height
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 50, 
              maxHeight: 150
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [                Row(
                  // Use mainAxisSize.min to prevent horizontal overflow
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: room.status.color.withValues( alpha: 0.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(room.status),
                            size: 14,
                            color: room.status.color,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            room.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: room.status.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Piso ${room.floor}', 
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey
                  )
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.thermostat, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${room.currentTemperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
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
