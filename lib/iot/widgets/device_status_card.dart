import 'package:flutter/material.dart';

enum DeviceType { temperature, humidity, ac, lighting, other }

extension DeviceTypeExtension on DeviceType {
  IconData get icon {
    switch (this) {
      case DeviceType.temperature:
        return Icons.thermostat_outlined;
      case DeviceType.humidity:
        return Icons.water_drop_outlined;
      case DeviceType.ac:
        return Icons.ac_unit;
      case DeviceType.lighting:
        return Icons.lightbulb_outline;
      case DeviceType.other:
        return Icons.device_hub;
    }
  }
  
  Color get color {
    switch (this) {
      case DeviceType.temperature:
        return Colors.red;
      case DeviceType.humidity:
        return Colors.blue;
      case DeviceType.ac:
        return Colors.purple;
      case DeviceType.lighting:
        return Colors.amber;
      case DeviceType.other:
        return Colors.grey;
    }
  }
}

class DeviceStatusCard extends StatelessWidget {
  final String deviceName;
  final bool isConnected;
  final DeviceType deviceType;
  final VoidCallback? onTap;

  const DeviceStatusCard({
    super.key,
    required this.deviceName,
    required this.isConnected,
    this.deviceType = DeviceType.other,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding
          child: SizedBox(
            height: 70, // Adjusted height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          color: deviceType.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          deviceType.icon,
                          color: deviceType.color,
                          size: 18, // Reduced icon size
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4), // Reduced height
                Flexible(
                  child: Text(
                    deviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12, // Reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                      fontSize: 10, // Reduced font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
