import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  late ReservationService _reservationService;
  late Reservation reservation;

  @override
  void initState() {
    super.initState();
    _reservationService = ReservationService();
    reservation = widget.reservation;
  }

  Future<void> _updateReservationStatus(String newStatus) async {
    try {
      await _reservationService.updateReservationStatus(reservation.id, newStatus);
      setState(() {
        // Create a new reservation with updated status
        reservation = Reservation(
          id: reservation.id,
          customerId: reservation.customerId,
          resourceId: reservation.resourceId,
          resourceType: reservation.resourceType,
          title: reservation.title,
          description: reservation.description,
          reservationDate: reservation.reservationDate,
          startTime: reservation.startTime,
          endTime: reservation.endTime,
          status: newStatus,
          guestCount: reservation.guestCount,
          totalAmount: reservation.totalAmount,
          specialRequests: reservation.specialRequests,
          hotelId: reservation.hotelId,
          createdAt: reservation.createdAt,
          updatedAt: DateTime.now(),
        );
      });
      _showSnackBar('Reservation status updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update status: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Confirm'),
                leading: const Icon(Icons.check_circle, color: Colors.green),
                onTap: () {
                  Navigator.pop(context);
                  _updateReservationStatus('confirmed');
                },
              ),
              ListTile(
                title: const Text('Cancel'),
                leading: const Icon(Icons.cancel, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  _updateReservationStatus('cancelled');
                },
              ),
              ListTile(
                title: const Text('Complete'),
                leading: const Icon(Icons.done_all, color: Colors.blue),
                onTap: () {
                  Navigator.pop(context);
                  _updateReservationStatus('completed');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (reservation.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: const Color(0xFF474C74),
        foregroundColor: Colors.white,
        actions: [
          if (reservation.status != 'completed' && reservation.status != 'cancelled')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showStatusUpdateDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(statusColor, statusIcon),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildDateTimeCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            _buildPaymentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Color statusColor, IconData statusIcon) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(height: 8),
            Text(
              reservation.status.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reservation.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Resource Type', reservation.resourceType.replaceAll('_', ' ').toUpperCase()),
            _buildInfoRow('Customer ID', reservation.customerId.toString()),
            _buildInfoRow('Resource ID', reservation.resourceId.toString()),
            _buildInfoRow('Guests', reservation.guestCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF474C74)),
                const SizedBox(width: 8),
                Text(
                  '${reservation.reservationDate.day}/${reservation.reservationDate.month}/${reservation.reservationDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF474C74)),
                const SizedBox(width: 8),
                Text(
                  '${reservation.startTime.hour}:${reservation.startTime.minute.toString().padLeft(2, '0')} - ${reservation.endTime.hour}:${reservation.endTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF474C74)),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${reservation.endTime.difference(reservation.startTime).inHours} hour(s)',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (reservation.specialRequests != null)
              _buildInfoRow('Special Requests', reservation.specialRequests!),
            _buildInfoRow('Created', '${reservation.createdAt.day}/${reservation.createdAt.month}/${reservation.createdAt.year}'),
            if (reservation.updatedAt != null)
              _buildInfoRow('Last Updated', '${reservation.updatedAt!.day}/${reservation.updatedAt!.month}/${reservation.updatedAt!.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '\$${reservation.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF474C74),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
