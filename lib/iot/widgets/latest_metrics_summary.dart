import 'package:flutter/material.dart';
import '../models/notification_history/notification_history.dart';

class LatestMetricsSummary extends StatelessWidget {
  final List<NotificationHistory> notifications;
  final String roomName;

  const LatestMetricsSummary({
    super.key,
    required this.notifications,
    required this.roomName,
  });

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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (notifications.isEmpty) {
      return Card(
        elevation: 2,
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.sensors,
                size: 48,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'Sin datos recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Los sensores no han enviado datos recientemente',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Get the most recent notification
    final latestNotification = notifications.first;
    final metrics = _parseMetrics(latestNotification.metric);

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sensors,
                  color: Colors.lightBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Métricas Recientes - $roomName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Metrics grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (metrics.containsKey('temp'))
                  SizedBox(
                    width: 120,
                    child: _buildMetricCard(
                      'Temperatura',
                      '${metrics['temp']}°C',
                      Icons.thermostat,
                      Colors.red,
                    ),
                  ),
                if (metrics.containsKey('hum'))
                  SizedBox(
                    width: 120,
                    child: _buildMetricCard(
                      'Humedad',
                      '${metrics['hum']}%',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                  ),
              ],
            ),
            
                        if (metrics.containsKey('motion') || metrics.containsKey('smoke'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (metrics.containsKey('motion'))
                      SizedBox(
                        width: 120,
                        child: _buildMetricCard(
                          'Movimiento',
                          metrics['motion'] ? 'Detectado' : 'Sin movimiento',
                          Icons.directions_walk,
                          metrics['motion'] ? Colors.green : Colors.grey,
                        ),
                      ),
                    if (metrics.containsKey('smoke'))
                      SizedBox(
                        width: 120,
                        child: _buildMetricCard(
                          'Nivel Humo',
                          '${metrics['smoke']}',
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
            
            if (metrics.containsKey('servo1') || metrics.containsKey('servo2'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (metrics.containsKey('servo1'))
                      SizedBox(
                        width: 120,
                        child: _buildMetricCard(
                          'Servo 1',
                          '${metrics['servo1']}°',
                          Icons.settings,
                          Colors.purple,
                        ),
                      ),
                    if (metrics.containsKey('servo2'))
                      SizedBox(
                        width: 120,
                        child: _buildMetricCard(
                          'Servo 2',
                          '${metrics['servo2']}°',
                          Icons.settings,
                          Colors.purple,
                        ),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            Text(
              'Última actualización: ${_formatDateTime(latestNotification.registrationDate)}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                fontStyle: FontStyle.italic,
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