import 'package:flutter/material.dart';
import '../models/iot_device/iot_device.dart';

class IotDeviceListTile extends StatelessWidget {
  final IoTDevice device;
  final VoidCallback? onTap;
  const IotDeviceListTile({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
