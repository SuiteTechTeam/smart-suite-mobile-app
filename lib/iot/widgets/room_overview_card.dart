import 'package:flutter/material.dart';
import '../models/room_summary.dart';

class RoomOverviewCard extends StatelessWidget {
  final int totalRooms;
  final int occupiedRooms;
  final int availableRooms;
  final int maintenanceRooms;
  
  const RoomOverviewCard({
    super.key, 
    required this.totalRooms,
    required this.occupiedRooms,
    required this.availableRooms,
    required this.maintenanceRooms,
  });
  
  // Constructor from list of rooms
  factory RoomOverviewCard.fromRooms(List<RoomSummary> rooms) {
    int occupied = 0;
    int available = 0;
    int maintenance = 0;
    
    for (final room in rooms) {
      switch (room.status) {
        case RoomOccupancyStatus.ocupada:
          occupied++;
          break;
        case RoomOccupancyStatus.libre:
          available++;
          break;
        case RoomOccupancyStatus.mantenimiento:
          maintenance++;
          break;
      }
    }
    
    return RoomOverviewCard(
      totalRooms: rooms.length,
      occupiedRooms: occupied,
      availableRooms: available,
      maintenanceRooms: maintenance,
    );
  }  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues( alpha: 0.2) 
                : Colors.grey.withValues( alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatusIndicator(
            label: "Total",
            value: totalRooms,
            color: Colors.grey[700]!,
            icon: Icons.hotel,
          ),
          _StatusIndicator(
            label: "Ocupadas",
            value: occupiedRooms,
            color: Colors.green,
            icon: Icons.person,
          ),
          _StatusIndicator(
            label: "Libres",
            value: availableRooms,
            color: Colors.blue,
            icon: Icons.check_circle,
          ),
          _StatusIndicator(
            label: "Mantenimiento",
            value: maintenanceRooms,
            color: Colors.orange,
            icon: Icons.handyman,
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData? icon;
  
  const _StatusIndicator({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Card(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
