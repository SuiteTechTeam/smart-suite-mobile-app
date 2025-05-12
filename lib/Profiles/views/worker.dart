import 'package:flutter/material.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

@override
Widget build(BuildContext context) { // Implements design for login view.
  return BaseLayout(role: '', childScreen: WorkerListScreen());
}

class WorkerListScreen extends StatelessWidget {
  final List<Map<String, String>> workers = [
    {'role': 'House Keeping', 'name': 'Juanito Alcachofa'},
    {'role': 'Recepcion', 'name': 'Germán Garmendia'},
    {'role': 'Security', 'name': 'Ruben Espinoza'},
    {'role': 'House Keeping', 'name': 'Alejandro Gutierrez'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Ingrese el nombre del trabajador',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            // List of workers
            Expanded(
              child: ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return WorkerCard(
                    role: worker['role']!,
                    name: worker['name']!,
                  );
                },
              ),
            ),
            // Invite worker button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Acción al invitar trabajador
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C4257),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Invitar trabajador',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String role;
  final String name;

  WorkerCard({required this.role, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon or image placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://img.freepik.com/vector-premium/ilustracion-plana-celebracion-dia-mundial-musica_52683-113650.jpg?w=740',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            // Worker details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(name, style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
