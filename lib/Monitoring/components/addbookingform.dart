import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/booking.dart';
import 'package:sweetmanager/Monitoring/models/customerr.dart';
import 'package:sweetmanager/Monitoring/services/bookingservice.dart';

class AddBookingForm extends StatefulWidget {
  const AddBookingForm({super.key});

  @override
  _AddBookingForm createState() => _AddBookingForm();
}

class _AddBookingForm extends State<AddBookingForm> {
  late BookingService bookingService = BookingService();
  late TextEditingController customerId;
  late TextEditingController username;
  late TextEditingController name;
  late TextEditingController surname;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController roomId;
  late TextEditingController description;
  late TextEditingController priceRoom;
  late TextEditingController nightCount;

  DateTime? startDate;
  DateTime? finalDate;

  @override
  void initState() {
    super.initState();
    customerId = TextEditingController();
    username = TextEditingController();
    name = TextEditingController();
    surname = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    roomId = TextEditingController();
    description = TextEditingController();
    priceRoom = TextEditingController();
    nightCount = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          finalDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: customerId,
              decoration: const InputDecoration(labelText: 'ClientId'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: surname,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            TextFormField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: roomId,
              decoration: const InputDecoration(labelText: 'RoomId'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'StartDate',
                hintText: startDate != null ? "${startDate!.toLocal()}".split(' ')[0] : 'Select date',
              ),
              onTap: () => _selectDate(context, true),
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'FinalDate',
                hintText: finalDate != null ? "${finalDate!.toLocal()}".split(' ')[0] : 'Select date',
              ),
              onTap: () => _selectDate(context, false),
            ),
            TextFormField(
              controller: priceRoom,
              decoration: const InputDecoration(labelText: 'Price room'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: nightCount,
              decoration: const InputDecoration(labelText: 'NightCount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (startDate == null || finalDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please, select dates')),
                  );
                  return;
                }

                await bookingService.createBooking(
                  Booking(
                    id: 0,
                    paymentCustomerId: 0,
                    roomId: int.parse(roomId.text),
                    description: description.text,
                    startDate: startDate!,
                    finalDate: finalDate!,
                    priceRoom: double.parse(priceRoom.text),
                    nightCount: int.parse(nightCount.text),
                    amount: 0,
                    bookingState: '',
                  ),
                  Customerr(
                    id: int.parse(customerId.text),
                    username: username.text,
                    name: name.text,
                    surname: surname.text,
                    email: email.text,
                    phone: int.parse(phone.text),
                    state: 'RESERVADO',
                  ),
                );

                Navigator.of(context).pop(true);
              },
              child: const Text('Save Booking'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    customerId.dispose();
    username.dispose();
    name.dispose();
    surname.dispose();
    email.dispose();
    phone.dispose();
    roomId.dispose();
    description.dispose();
    priceRoom.dispose();
    nightCount.dispose();
    super.dispose();
  }
}
