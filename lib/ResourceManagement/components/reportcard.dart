import 'package:flutter/material.dart';
import 'package:sweetmanager/ResourceManagement/models/report.dart';

class ReportCard extends StatelessWidget {
  final Report report; 
  final int index; 

  const ReportCard({super.key, required this.report, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(report.title), // Accede a la propiedad dinámica report.title
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.description, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4), 
            report.fileUrl.isNotEmpty
                ? Image.network(report.fileUrl) // Usamos la URL de Firebase Storage
                : const Text('No image available'), // Mensaje si no hay URL
          ],
        ),
        trailing: const Icon(Icons.more_vert), 
      ),
    );
  }
}