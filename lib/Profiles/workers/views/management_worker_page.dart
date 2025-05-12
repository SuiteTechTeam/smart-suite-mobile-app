import 'package:flutter/material.dart';
import 'package:sweetmanager/Profiles/workers/models/worker_model.dart'; // Importa el modelo Worker
import 'package:sweetmanager/Profiles/workers/views/add_worker.dart'; // Importa la pantalla para agregar worker
import 'package:sweetmanager/Profiles/workers/services/workerservices.dart'; // Importa el servicio para obtener workers
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart'; // Importa tu BaseLayout

class WorkerManagement extends StatefulWidget {
  const WorkerManagement({super.key});

  @override
  State<WorkerManagement> createState() => _WorkerManagementState();
}

class _WorkerManagementState extends State<WorkerManagement> {
  late Workerservice _workerService;
  final storage = const FlutterSecureStorage();
  List<Worker> workers = [];
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
    _workerService = Workerservice();
    _loadHotelId();
  }

  Future<void> _loadHotelId() async {
    int? tokenHotelId = await _getHotelId();
    print('Hotel ID: $tokenHotelId');

    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      _fetchWorkers();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

  Future<void> _fetchWorkers() async {
    if (hotelId == null) return;

    try {
      print('Fetching workers for hotelId: $hotelId');
      List<Worker> fetchedWorkers = await _workerService.getWorkersByHotelId(hotelId!);
      print('Fetched workers: $fetchedWorkers');
      setState(() {
        workers = fetchedWorkers;;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching workers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load workers: $e')),
      );
    }
  }

  Future<void> _addWorker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkerAddScreen()),
    );

    if (result == true) {
      await _fetchWorkers(); // Refresca la lista después de agregar un nuevo worker
    }
  }

  @override
  Widget build(BuildContext context) {

    if (workers.isEmpty) {
      return const Center(
        child: Text(
          'There are no workers records yet',
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
                          'Workers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addWorker,
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
                        rows: workers.map((worker) {
                          return DataRow(
                            cells: [
                              DataCell(Text(worker.id?.toString() ?? 'N/A')), // Mostrar el ID
                              DataCell(Text(worker.name ?? 'N/A')),  // Si name es null, mostrar 'N/A'
                              DataCell(Text(worker.surname ?? 'N/A')),  // Si surname es null, mostrar 'N/A'
                              DataCell(Text(worker.email ?? 'N/A')),  // Si email es null, mostrar 'N/A'
                              DataCell(Text(worker.phone?.toString() ?? 'N/A')),  // Convertir phone a String si no es null
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
