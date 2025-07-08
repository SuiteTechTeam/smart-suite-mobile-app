import 'package:flutter/material.dart';
import '../models/available_room.dart';

class AvailableRoomSelection extends StatelessWidget {
  final List<AvailableRoom> availableRooms;
  final int? selectedRoomId;
  final Function(int?) onRoomSelected;
  final bool isLoading;

  const AvailableRoomSelection({
    super.key,
    required this.availableRooms,
    required this.selectedRoomId,
    required this.onRoomSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cargando habitaciones disponibles...'),
            ],
          ),
        ),
      );
    }

    if (availableRooms.isEmpty) {
      return const Card(
        color: Colors.orange,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'No hay habitaciones disponibles para las fechas seleccionadas',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habitaciones Disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...availableRooms.map((room) => _buildRoomCard(room)).toList(),
      ],
    );
  }

  Widget _buildRoomCard(AvailableRoom room) {
    final isSelected = selectedRoomId == room.room.id;
    final isAvailable = room.isAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? const Color(0xFF474C74) : null,
      child: InkWell(
        onTap: isAvailable ? () => onRoomSelected(room.room.id) : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Room icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAvailable 
                      ? (isSelected ? Colors.white : const Color(0xFF474C74))
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bed,
                  color: isAvailable 
                      ? (isSelected ? const Color(0xFF474C74) : Colors.white)
                      : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Room details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (room.typeRoom != null)
                      Text(
                        room.typeRoom!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      room.priceDisplay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF474C74),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable ? 'Disponible' : 'Ocupada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 