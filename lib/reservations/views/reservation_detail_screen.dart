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
      await _reservationService.updateReservationStatus(reservation.id!, newStatus);
      setState(() {
        reservation = Reservation(
          id: reservation.id,
          paymentCustomerId: reservation.paymentCustomerId,
          roomId: reservation.roomId,
          description: reservation.description,
          startDate: reservation.startDate,
          finalDate: reservation.finalDate,
          priceRoom: reservation.priceRoom,
          nightCount: reservation.nightCount,
          amount: reservation.amount,
          state: newStatus,
          preferenceId: reservation.preferenceId,
          createdAt: reservation.createdAt,
          updatedAt: DateTime.now(),
        );
      });
      _showSnackBar('Booking status updated successfully');
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

    switch (reservation.state) {
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
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF474C74),
        foregroundColor: Colors.white,
        actions: [
          if (reservation.state != 'completed' && reservation.state != 'cancelled')
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(height: 8),
            Text(
              reservation.state.toUpperCase(),
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
            const Text(
              'Booking Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Booking ID:', '${reservation.id ?? 'N/A'}'),
            _buildInfoRow('Room ID:', '${reservation.roomId}'),
            _buildInfoRow('Customer ID:', '${reservation.paymentCustomerId}'),
            const SizedBox(height: 8),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              reservation.description.isNotEmpty ? reservation.description : 'No description provided',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
              'Stay Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Check-in:', _formatDate(reservation.startDate)),
            _buildInfoRow('Check-out:', _formatDate(reservation.finalDate)),
            _buildInfoRow('Number of Nights:', '${reservation.nightCount}'),
            const SizedBox(height: 8),
            if (reservation.createdAt != null)
              _buildInfoRow('Booked on:', _formatDateTime(reservation.createdAt!)),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Room Price per Night:', '\$${reservation.priceRoom.toStringAsFixed(2)}'),
            _buildInfoRow('Number of Nights:', '${reservation.nightCount}'),
            const Divider(),
            _buildInfoRow(
              'Total Amount:',
              '\$${reservation.amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            _buildInfoRow('Preference ID:', '${reservation.preferenceId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
