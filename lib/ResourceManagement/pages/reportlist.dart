import 'package:flutter/material.dart';
import 'package:sweetmanager/ResourceManagement/components/reportcard.dart';
import 'package:sweetmanager/ResourceManagement/pages/addreport.dart';
import 'package:sweetmanager/ResourceManagement/models/report.dart';
import 'package:sweetmanager/ResourceManagement/services/reportservice.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isSearching = false;
  bool isLoading = true;
  List<Report> reports = [];
  List<Report> filteredReports = [];
  late ReportService reportService;
  final storage = const FlutterSecureStorage();
  String? role;
  int? hotelId;

  @override
  void initState() {
    super.initState();
    reportService = ReportService();
    _loadHotelId();
  }

  Future<String?> _getRole() async {
  String? token = await storage.read(key: 'token');
  if (token != null) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? decodedRole = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    print('Decoded role: $decodedRole'); // Verificar el valor del rol
    return decodedRole;
  }
  return null;
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
      fetchReports();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

  Future<void> fetchReports() async {
    try {
      print('Fetching supplies for hotelId: $hotelId');
      final List<dynamic> reportData = await reportService.getReports(hotelId!);
      setState(() {
        reports = reportData.map((data) => Report.fromJson(data)).toList();
        filteredReports = reports;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching reports: $e');
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
      print('Role in build: $role'); // Verificar el valor de `role` en tiempo de construcción

      return BaseLayout(
        role: role,
        childScreen: Scaffold(
          body: Column(
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
                        'Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          isSearching
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        filteredReports = reports.where((report) {
                                          return report.title.toLowerCase().contains(searchQuery.toLowerCase());
                                        }).toList();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search reports',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                isSearching = !isSearching;
                                if (!isSearching) {
                                  searchController.clear();
                                  searchQuery = "";
                                  filteredReports = reports;
                                }
                              });
                            },
                          ),
                          // Mostrar el botón de más solo si el rol es '3'
                          if (role == "ROLE_WORKER")
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddReport(),
                                  ),
                                );

                                // Si un nuevo reporte fue agregado exitosamente, recargar la lista de reportes
                                if (result == true) {
                                  _loadHotelId();
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ReportCard(report: filteredReports[index], index: index),
                            );
                          },
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