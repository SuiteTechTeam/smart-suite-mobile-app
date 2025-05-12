import 'package:flutter/material.dart';
import 'package:sweetmanager/supply-management/models/supply.dart';
import 'package:sweetmanager/supply-management/views/supplyaddscreen.dart';
import 'package:sweetmanager/supply-management/views/supplyeditscreen.dart';
import 'package:sweetmanager/supply-management/services/supplyservices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart'; // Import your BaseLayout

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  late SupplyService _supplyService;
  final storage = const FlutterSecureStorage();
  List<Supply> supplies = [];
  bool isLoading = true;
  int? hotelId;
  String? role;
  
  // Método para obtener el rol del token
  Future<String?> _getRole() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    }
    return null;
  }
  
  // Método para obtener el hotelId desde el token
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

  @override
  void initState() {
    super.initState();
    _supplyService = SupplyService();
    _loadHotelId();
  }

  Future<void> _loadHotelId() async {
    int? tokenHotelId = await _getHotelId();
    print('Hotel ID: $tokenHotelId');

    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      _fetchSupplies();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

  Future<void> _fetchSupplies() async {
    if (hotelId == null) return;

    try {
      print('Fetching supplies for hotelId: $hotelId');
      List<dynamic> fetchedSupplies = await _supplyService.getSuppliesByHotelId(hotelId!);
      print('Fetched supplies: $fetchedSupplies');
      setState(() {
        supplies = fetchedSupplies.map((data) => Supply.fromJson(data)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching supplies: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load supplies: $e')),
      );
    }
  }

  Future<void> _addSupply() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SupplyAddScreen()),
  );

  if (result == true) {
    await _fetchSupplies(); // Refresca la lista después de agregar
  }
}


  void _showDeleteConfirmationDialog(Supply supply) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete supply"),
          content: Text('Are you sure you want to delete this supply: "${supply.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteSupply(supply);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSupply(Supply supply) async {
    setState(() {
      isLoading = true;
    });

    try {
      await _supplyService.deleteSupply(supply.id);
      setState(() {
        supplies.remove(supply);
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supply deleted successfully')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error deleting supply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed at deleting supply: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading role'));
        }
        
        role = snapshot.data;

        return BaseLayout(
          role: role,
          childScreen: Scaffold(
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Supplies',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _addSupply,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  return const Color(0xFF474C74);
                                },
                              ),
                              dataRowColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.grey.withOpacity(0.5);
                                  }
                                  return Colors.white;
                                },
                              ),
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'ID',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Product',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Quantity',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              rows: supplies.map((supply) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(supply.id.toString())),
                                    DataCell(Text(supply.name)),
                                    DataCell(Text(supply.stock.toString())),
                                    DataCell(
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SupplyEditScreen(supply: supply),
                                                ),
                                              );

                                              if (result == true) {
                                                _fetchSupplies();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF474C74),
                                            ),
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(supply);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}