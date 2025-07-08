import 'package:flutter/material.dart';
import '../models/available_room.dart';
import 'package:intl/intl.dart';

class BookingSummaryCard extends StatelessWidget {
  final AvailableRoom selectedRoom;
  final DateTime startDate;
  final DateTime finalDate;
  final String description;
  final int guestCount;
  final String? specialRequests;

  const BookingSummaryCard({
    super.key,
    required this.selectedRoom,
    required this.startDate,
    required this.finalDate,
    required this.description,
    required this.guestCount,
    this.specialRequests,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    int nightCount = finalDate.difference(startDate).inDays;
    if (nightCount <= 0) nightCount = 1;
    
    double totalAmount = selectedRoom.pricePerNight * nightCount;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.summarize,
                  color: Color(0xFF474C74),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumen de Reservación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF474C74),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Room information
            _buildInfoRow(
              'Habitación:',
              selectedRoom.displayName,
              Icons.bed,
            ),
            _buildInfoRow(
              'Tipo:',
              selectedRoom.typeRoom?.description ?? 'No especificado',
              Icons.category,
            ),
            _buildInfoRow(
              'Precio por noche:',
              selectedRoom.priceDisplay,
              Icons.attach_money,
            ),
            
            const Divider(height: 24),
            
            // Dates
            _buildInfoRow(
              'Fecha de llegada:',
              '${dateFormat.format(startDate)} a las ${timeFormat.format(startDate)}',
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'Fecha de salida:',
              '${dateFormat.format(finalDate)} a las ${timeFormat.format(finalDate)}',
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'Número de noches:',
              '$nightCount noche${nightCount > 1 ? 's' : ''}',
              Icons.nights_stay,
            ),
            
            const Divider(height: 24),
            
            // Guest information
            _buildInfoRow(
              'Número de huéspedes:',
              '$guestCount huésped${guestCount > 1 ? 'es' : ''}',
              Icons.people,
            ),
            
            if (description.isNotEmpty)
              _buildInfoRow(
                'Descripción:',
                description,
                Icons.description,
              ),
            
            if (specialRequests != null && specialRequests!.isNotEmpty)
              _buildInfoRow(
                'Solicitudes especiales:',
                specialRequests!,
                Icons.note,
              ),
            
            const Divider(height: 24),
            
            // Total calculation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF474C74).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '\$${selectedRoom.pricePerNight.toStringAsFixed(2)} × $nightCount noche${nightCount > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF474C74),
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF474C74),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 