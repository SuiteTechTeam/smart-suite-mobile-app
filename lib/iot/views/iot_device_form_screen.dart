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
  final IotService _service = IotService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final resource = CreateIoTDeviceResource(
      name: _nameController.text,
    );
    try {
      await _service.createIotDevice(resource);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el dispositivo: ${e.toString()}')),
        );
      }
      return;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
