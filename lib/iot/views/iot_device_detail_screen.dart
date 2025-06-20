import 'package:flutter/material.dart';
import '../services/iot_service.dart';
import '../models/iot_device/iot_device.dart';
import '../models/iot_device/update_iot_device_resource.dart';
import '../models/room_device/room_device.dart';
import '../widgets/room_device_list_tile.dart';
import '../widgets/notification_history_list_tile.dart';

class IotDeviceDetailScreen extends StatefulWidget {
  final int deviceId;
  const IotDeviceDetailScreen({super.key, required this.deviceId});

  @override
  State<IotDeviceDetailScreen> createState() => _IotDeviceDetailScreenState();
}

class _IotDeviceDetailScreenState extends State<IotDeviceDetailScreen> {
  final IotService _service = IotService();
  late Future<IoTDevice> _deviceFuture;
  late Future<List<RoomDevice>> _roomDevicesFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _service.getIotDeviceByID(widget.deviceId);
    _roomDevicesFuture = _service.getRoomDeviceById(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Dispositivo')),
      body: FutureBuilder<IoTDevice>(
        future: _deviceFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final device = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('ID: [34m${device.id}[0m', style: Theme.of(context).textTheme.titleLarge),
              Text('Nombre: ${device.name}'),
              Text('Tipo: ${device.type}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Navegar a pantalla de edición (puedes reutilizar el formulario)
                },
                child: const Text('Editar'),
              ),
              const Divider(),
              const Text('Room Devices asociados:'),
              FutureBuilder<List<RoomDevice>>(
                future: _roomDevicesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final roomDevices = snapshot.data!;
                  if (roomDevices.isEmpty) {
                    return const Text('No hay Room Devices asociados.');
                  }
                  return Column(
                    children: roomDevices.map((rd) => RoomDeviceListTile(roomDevice: rd)).toList(),
                  );
                },
              ),
              // Aquí puedes agregar historial de notificaciones si lo deseas
            ],
          );
        },
      ),
    );
  }
}
