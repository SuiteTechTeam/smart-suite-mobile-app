import 'package:flutter/material.dart';
import '../services/iot_service.dart';
import '../models/iot_device/iot_device.dart';
import 'iot_device_detail_screen.dart';
import 'iot_device_form_screen.dart';
import '../widgets/iot_device_list_tile.dart';

class IotDeviceListScreen extends StatefulWidget {
  const IotDeviceListScreen({super.key});

  @override
  State<IotDeviceListScreen> createState() => _IotDeviceListScreenState();
}

class _IotDeviceListScreenState extends State<IotDeviceListScreen> {
  final IotService _service = IotService();
  late Future<List<IoTDevice>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _devicesFuture = _service.getAllIotDevices();
  }

  void _refresh() {
    setState(() {
      _devicesFuture = _service.getAllIotDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos IoT')),
      body: FutureBuilder<List<IoTDevice>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: [31m${snapshot.error}[0m'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay dispositivos.'));
          }
          final devices = snapshot.data!;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return IotDeviceListTile(
                device: devices[index],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IotDeviceDetailScreen(deviceId: devices[index].id),
                    ),
                  );
                  _refresh();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IotDeviceFormScreen()),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
