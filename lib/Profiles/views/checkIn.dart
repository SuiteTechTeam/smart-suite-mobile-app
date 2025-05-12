import 'package:flutter/material.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

@override
Widget build(BuildContext context) { // Implements design for login view.
  return BaseLayout(role: '', childScreen: CheckInScreen());
}

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  List<Map<String, dynamic>> customers = [
    {'name': 'Jane Cooper', 'room': '1423', 'date': '01/01/2024'},
    {'name': 'Floyd Miles', 'room': '2314', 'date': '05/01/2024'},
    {'name': 'Ronald Richards', 'room': '802', 'date': '10/01/2024'},
    {'name': 'Marvin McKinney', 'room': '1523', 'date': '15/01/2024'},
    {'name': 'Jerome Bell', 'room': '1145', 'date': '20/01/2024'},
    {'name': 'Kathryn Murphy', 'room': '1120', 'date': '21/02/2024'},
    {'name': 'Jacob Jones', 'room': '301', 'date': '26/03/2024'},
    {'name': 'Kristin Watson', 'room': '802', 'date': '31/03/2024'},
    {'name': 'Alice Johnson', 'room': '105', 'date': '05/04/2024'},
    {'name': 'Robert Smith', 'room': '245', 'date': '10/04/2024'},
    {'name': 'Emily Davis', 'room': '512', 'date': '15/04/2024'},
  ];

  int currentPage = 1;
  int customersPerPage = 8;

  void _addCustomer(String name, String room, String date) {
    setState(() {
      customers.add({'name': name, 'room': room, 'date': date});
    });
  }

  void _showAddCustomerDialog() {
    String newName = '';
    String newRoom = '';
    String newDate = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Customer Name'),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Room'),
                onChanged: (value) {
                  newRoom = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Check-in Date'),
                onChanged: (value) {
                  newDate = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (newName.isNotEmpty && newRoom.isNotEmpty && newDate.isNotEmpty) {
                  _addCustomer(newName, newRoom, newDate);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (customers.length / customersPerPage).ceil();
    List<Map<String, dynamic>> customersForPage = customers.skip((currentPage - 1) * customersPerPage).take(customersPerPage).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título de la pantalla "Sweet Manager"
            Text(
              'Sweet Manager',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C4257),
              ),
            ),
            SizedBox(height: 16),
            // Header con "Check-in" centrado y botón a la derecha
            Row(
              children: [
                Spacer(),
                Text(
                  'Check-in',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 30),
                  onPressed: _showAddCustomerDialog,
                ),
              ],
            ),
            SizedBox(height: 16),
            // Header de la tabla
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 2, child: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 1, child: Text('Room', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  SizedBox(width: 50),
                  Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.right)),
                ],
              ),
            ),
            Divider(thickness: 2),
            // Lista de clientes
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: customersForPage.length,
                itemBuilder: (context, index) {
                  final customer = customersForPage[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 2, child: Text(customer['name'])),
                          Expanded(flex: 1, child: Text(customer['room'], textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text(customer['date'], textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            // Paginación dinámica
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPage = index + 1;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: currentPage == index + 1 ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Color(0xFF1C4257)),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: currentPage == index + 1 ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
