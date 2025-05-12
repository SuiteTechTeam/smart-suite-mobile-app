import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/models/owner_entity.dart';
import 'package:sweetmanager/supply-management/services/paymentownerservices.dart';
import 'package:sweetmanager/supply-management/services/supplyrequestservices.dart';
import 'package:sweetmanager/supply-management/services/supplyservices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class SupplyAddScreen extends StatefulWidget {
  const SupplyAddScreen({super.key});

  @override
  State<SupplyAddScreen> createState() => _SupplyAddScreenState();
}

class _SupplyAddScreenState extends State<SupplyAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _providersIdController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  int? hotelId;

  bool isLoading = false;

  late SupplyService _supplyService;
  late SupplyRequestService _supplyRequestService;
  late PaymentOwnerService _paymentOwnerService;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _supplyService = SupplyService();
    _supplyRequestService = SupplyRequestService();
    _paymentOwnerService = PaymentOwnerService(); // Asegúrate de inicializarlo aquí
  }

  Future<String?> _getIdentity() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }

  Future<int?> _getHotelId() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'] != null) {
        try {
          return int.parse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']);
        } catch (e) {
          print('Failed to Convert Hotel ID $e');
          return null;
        }
      } else {
        print('Hotel ID not found');
        return null;
      }
    }
    return null;
  }

  Future<void> _loadHotelId() async {
    int? tokenHotelId = await _getHotelId();
    print('Hotel ID: $tokenHotelId');

    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      _addSupply();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

Future<void> _addSupply() async {
  int? tokenHotelId = await _getHotelId();
  String? ownerid = await _getIdentity();
  int providerId = int.parse(_providersIdController.text);

  setState(() {
    isLoading = true;
  });

  try {
    // Paso 1: Crear el Supply
    Map<String, dynamic> newSupply = {
      'name': _nameController.text,
      'providersId': providerId,
      'stock': int.parse(_stockController.text),
      'price': double.parse(_priceController.text),
      'state': _stateController.text,
    };
    await _supplyService.createSupply(newSupply);

    // Paso 2: Obtener el SupplyId del Supply recién creado usando el providerId
    final supplies = await _supplyService.getSuppliesByProviderId(providerId);
if (supplies.isNotEmpty) {
  final int newSupplyId = int.parse(supplies.last['id'].toString()); // Convierte el ID a int si es necesario


      // Paso 3: Crear el PaymentOwner
      if (ownerid != null) {
        Map<String, dynamic> newPaymentOwner = {
          'ownerId': ownerid,
          'description': 'Payment for supply ${_nameController.text}',
          'finalAmount': double.parse(_priceController.text),
        };

        await _paymentOwnerService.createPaymentOwner(newPaymentOwner);
        
        // Paso 4: Obtener el ID del último PaymentOwner creado usando getPaymentsByOwnerId
        final payments = await _paymentOwnerService.getPaymentsByOwnerId(int.parse(ownerid));
        if (payments.isNotEmpty) {
          final int newPaymentOwnerId = int.parse(payments.last['id'].toString()); // Último PaymentOwner creado

          // Paso 5: Crear el SupplyRequest con los IDs obtenidos
          Map<String, dynamic> newSupplyRequest = {
            'paymentsOwnersId': newPaymentOwnerId,
            'suppliesId': newSupplyId,
            'count': int.parse(_stockController.text),
            'amount': double.parse(_priceController.text).toStringAsFixed(2), // Asegura que amount sea un decimal con dos dígitos
          };

print("Sending supplyRequest: ${json.encode(newSupplyRequest)}"); // Imprime el JSON enviado

          await _supplyRequestService.createSupplyRequest(newSupplyRequest);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supply added successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception("No se encontraron pagos para el Owner ID especificado.");
        }
      } else {
        throw Exception('Owner ID is null');
      }
    } else {
      throw Exception("No se encontró ningún Supply para el Provider ID especificado.");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add supply: $e')),
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
                    'Add Supply',
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
                                  onPressed: _addSupply,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF474C74),
                                  ),
                                  child: const Text(
                                    'Add Supply',
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
