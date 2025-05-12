import 'package:flutter/material.dart';
import 'package:sweetmanager/Profiles/admins/models/admin_model.dart'; // Importa el modelo Admin
import 'package:sweetmanager/Profiles/admins/views/add_admin.dart'; // Importa la pantalla para agregar admin
import 'package:sweetmanager/Profiles/admins/services/adminservices.dart'; // Importa el servicio para obtener administradores
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart'; // Importa tu BaseLayout

class AdminManagement extends StatefulWidget {
  const AdminManagement({super.key});

  @override
  State<AdminManagement> createState() => _AdminManagementState();
}

class _AdminManagementState extends State<AdminManagement> {
  late AdminService _adminService;
  final storage = const FlutterSecureStorage();
  List<Admin> admins = [];
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
    _adminService = AdminService();
    _loadHotelId();
  }

  Future<void> _loadHotelId() async {
    int? tokenHotelId = await _getHotelId();
    print('Hotel ID: $tokenHotelId');

    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      _fetchAdmins();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

  Future<void> _fetchAdmins() async {
    if (hotelId == null) return;

    try {
      print('Fetching admins for hotelId: $hotelId');
      List<Admin> fetchedAdmins = await _adminService.getAdminsByHotelId(hotelId!);
      print('Fetched admins: $fetchedAdmins');
      setState(() {
        admins = fetchedAdmins;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching admins: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load admins: $e')),
      );
    }
  }

  Future<void> _addAdmin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAddScreen()),
    );

    if (result == true) {
      await _fetchAdmins(); // Refresca la lista después de agregar un nuevo admin
    }
  }

  @override
  Widget build(BuildContext context) {
    if (admins.isEmpty) {
      return const Center(
        child: Text(
          'There are no admins records yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
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
                          'Admins',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addAdmin,
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
                                'Name',
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
                                'Surname',
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
                                'Email',
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
                                'Phone',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: admins.map((admin) {
                          return DataRow(
                            cells: [
                              DataCell(Text(admin.id?.toString() ?? 'N/A')), // Mostrar el ID
                              DataCell(Text(admin.name?? 'N/A')),  // Si name es null, mostrar 'N/A'
                              DataCell(Text(admin.surname?? 'N/A')),  // Si surname es null, mostrar 'N/A'
                              DataCell(Text(admin.email?? 'N/A')),  // Si email es null, mostrar 'N/A'
                              DataCell(Text(admin.phone?.toString() ?? 'N/A')),  // Convertir phone a String si no es null
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

