import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/iot_device/iot_device.dart';

class IotDeviceListTile extends StatelessWidget {
  final IoTDevice device;
  final VoidCallback? onTap;

  const IotDeviceListTile({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
