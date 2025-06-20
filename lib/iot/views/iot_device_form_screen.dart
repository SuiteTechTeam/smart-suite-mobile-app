import 'package:flutter/material.dart';
import '../services/iot_service.dart';
import '../models/iot_device/create_iot_device_resource.dart';

class IotDeviceFormScreen extends StatefulWidget {
  final int? deviceId;
  const IotDeviceFormScreen({super.key, this.deviceId});

  @override
  State<IotDeviceFormScreen> createState() => _IotDeviceFormScreenState();
}

class _IotDeviceFormScreenState extends State<IotDeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final IotService _service = IotService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final resource = CreateIoTDeviceResource(
      name: _nameController.text,
      type: _typeController.text,
    );
    await _service.createIotDevice(resource);
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Dispositivo IoT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un tipo' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Guardar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
