import 'package:flutter/material.dart';
import '../models/notification_history/notification_history.dart';

class NotificationHistoryListTile extends StatelessWidget {
  final NotificationHistory notification;
  const NotificationHistoryListTile({super.key, required this.notification});

  Map<String, dynamic> _parseMetrics(String metricString) {
    final Map<String, dynamic> metrics = {};
    final parts = metricString.split(';');
    
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0];
        final value = keyValue[1];
        
        // Parse boolean values first
        if (value.toLowerCase() == 'true') {
          metrics[key] = true;
        } else if (value.toLowerCase() == 'false') {
          metrics[key] = false;
        }
        // Parse numeric values
        else if (value.contains('.')) {
          metrics[key] = double.tryParse(value) ?? value;
        } else {
          metrics[key] = int.tryParse(value) ?? value;
        }
      }
    }
    
    return metrics;
  }

  Widget _buildMetricChip(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final metrics = _parseMetrics(notification.metric);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dispositivo #${notification.roomDeviceId}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  _formatDateTime(notification.registrationDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Metrics display
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (metrics.containsKey('temp'))
                  _buildMetricChip('Temp', '${metrics['temp']}°C', Colors.red),
                if (metrics.containsKey('hum'))
                  _buildMetricChip('Humedad', '${metrics['hum']}%', Colors.blue),
                if (metrics.containsKey('motion'))
                  _buildMetricChip('Movimiento', metrics['motion'] ? 'Sí' : 'No', 
                    metrics['motion'] ? Colors.green : Colors.grey),
                if (metrics.containsKey('smoke'))
                  _buildMetricChip('Humo', '${metrics['smoke']}', Colors.orange),
                if (metrics.containsKey('servo1'))
                  _buildMetricChip('Servo1', '${metrics['servo1']}°', Colors.purple),
                if (metrics.containsKey('servo2'))
                  _buildMetricChip('Servo2', '${metrics['servo2']}°', Colors.purple),
              ],
            ),
            
            if (metrics.containsKey('stamp'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Stamp: ${metrics['stamp']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Ahora';
    }
  }
}
