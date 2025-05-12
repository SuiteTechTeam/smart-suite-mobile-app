import 'package:flutter/material.dart';
import 'package:sweetmanager/supply-management/services/supplyservices.dart';
import 'package:sweetmanager/supply-management/models/supply.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SupplyEditScreen extends StatefulWidget {
  final Supply supply;

  const SupplyEditScreen({super.key, required this.supply});

  @override
  State<SupplyEditScreen> createState() => _SupplyEditScreenState();
}

class _SupplyEditScreenState extends State<SupplyEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _providersIdController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late TextEditingController _stateController;

  bool isLoading = false;

  late SupplyService _supplyService;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> _getRole() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _supplyService = SupplyService();

    _nameController = TextEditingController(text: widget.supply.name);
    _providersIdController = TextEditingController(text: widget.supply.providersId.toString());
    _stockController = TextEditingController(text: widget.supply.stock.toString());
    _priceController = TextEditingController(text: widget.supply.price.toString());
    _stateController = TextEditingController(text: widget.supply.state);
  }

  Future<void> _updateSupply() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Crear un mapa con los datos del suministro actualizado
      Map<String, dynamic> updatedSupply = {
        'name': _nameController.text,
        'providersId': int.parse(_providersIdController.text),
        'stock': int.parse(_stockController.text),
        'price': double.parse(_priceController.text),
        'state': _stateController.text,
      };

      // Llamar al servicio para actualizar el suministro
      await _supplyService.updateSupply(widget.supply.id, updatedSupply);

      // Mostrar un mensaje de éxito y regresar con un resultado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supply updated successfully')),
      );
      Navigator.of(context).pop(true); // Regresar con un resultado de éxito
    } catch (e) {
      // Manejar errores con un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update supply: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop(); // Regresar a la pantalla anterior
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Supply',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF474C74),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.label),
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _providersIdController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person_2),
                          labelText: 'Provider ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.shopping_cart),
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.attach_money),
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.check_circle),
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _updateSupply,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF474C74),
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
                    ],
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


  @override
  void dispose() {
    _nameController.dispose();
    _providersIdController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
