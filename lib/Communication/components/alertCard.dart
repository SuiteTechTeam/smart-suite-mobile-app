import 'package:flutter/material.dart';
import 'package:sweetmanager/Communication/models/notification.dart';

class AlertCard extends StatelessWidget {
  final Notifications alert;
  final String level;
  final int index;
  final void Function(int) removeAlert;

  const AlertCard({
    super.key,
    required this.alert,
    required this.level,
    required this.index,
    required this.removeAlert,
  });

  Color getLevelColor() {
    switch (level) {
      case 'Warning':
        return Colors.orange;
      case 'Important':
        return Colors.red;
      case 'Security':
        return Colors.blueAccent;
      case 'Extreme':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warning,
          color: getLevelColor(),
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alert.description!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                level,
                style: TextStyle(
                  fontSize: 14,
                  color: getLevelColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'Delete') {
              removeAlert(index);
            } else if (value == 'View Details') {
              // Add logic to view details of the alert
            }
          },
          itemBuilder: (BuildContext context) {
            return const {'Delete', 'View Details'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
