import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/services/roomservice.dart';

import '../models/booking.dart';
import '../services/bookingservice.dart';

class DetailBooking extends StatefulWidget {
  final int id;

  const DetailBooking({super.key, required this.id});

  @override
  _DetailBookingState createState() => _DetailBookingState();
}

class _DetailBookingState extends State<DetailBooking> {
  late int id;
  Map<String, dynamic>? information;
  late RoomService roomService;
  late BookingService bookingService;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _getInformationById(id);
  }

  Future<void> _getInformationById(int id) async {

    bookingService = BookingService();
    roomService = RoomService();

    Booking booking = await bookingService.getBookingById(id.toString());
    Room room = await roomService.getRoomById(booking.roomId.toString());

    setState(() {
      information = {
        'CustomerName': booking.paymentCustomerId,
        'BookingId': booking.id,
        'StartDate': booking.startDate,
        'FinalDate': booking.finalDate,
        'RoomId': room.id,
        'TypeRoom': room.typeRoomId,
        'RoomState': room.roomState,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: information == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            width: double.infinity,
            height: 150.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/deluxe_bedroom.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Customer name'),
                    Text(information!['CustomerName'].toString()),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Booking Code'),
                    Text(information!['BookingId'].toString()),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start Date'),
                    Text(information!['StartDate'].toString()),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('FinalDate'),
                    Text(information!['FinalDate'].toString()),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 150.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/suite_executive.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Room Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Room Code'),
                    Text(information!['RoomId'].toString()),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Type Room'),
                    Text(information!['TypeRoom'].toString()),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Room State'),
                    Text(information!['RoomState'].toString()),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Center(
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}