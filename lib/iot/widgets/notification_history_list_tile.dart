import 'package:flutter/material.dart';
import '../models/notification_history/notification_history.dart';

class NotificationHistoryListTile extends StatelessWidget {
  final NotificationHistory notification;
  const NotificationHistoryListTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.message),
      subtitle: Text('Fecha: ${notification.createdAt}'),
    );
  }
}
