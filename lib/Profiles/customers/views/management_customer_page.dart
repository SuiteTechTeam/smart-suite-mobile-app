import 'package:flutter/material.dart';
import 'package:sweetmanager/Profiles/customers/models/customer_model.dart';
import 'package:sweetmanager/Profiles/customers/services/customerservices.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class CustomersManagement extends StatefulWidget {
  const CustomersManagement({super.key});

  @override
  State<CustomersManagement> createState() => _CustomersManagementState();
}

class _CustomersManagementState extends State<CustomersManagement> {
  late Customerservice _customerService;
  late AuthService _authService;
  final storage = const FlutterSecureStorage();
  List<Customer> customers = [];
  bool isLoading = true;
  int? hotelId;
  String? role;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _customerService = Customerservice();
    _loadHotelId();
  }

  Future<void> _loadHotelId() async {
    hotelId = await _getHotelId();
    if (hotelId != null) {
      await _fetchCustomers();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Hotel ID not found');
    }
  }

  Future<String?> _getRole() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    }
    return null;
  }

  Future<int?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? locality = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'];
      return locality != null ? int.tryParse(locality) : null;
    }
    return null;
  }

  Future<void> _fetchCustomers() async {
    if (hotelId == null) return;

    try {
      List<Customer> fetchedCustomers = await _customerService.getCustomerByHotelId(hotelId!);
      setState(() {
        customers = fetchedCustomers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Failed to load customers: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                _buildHeader(),
                const SizedBox(height: 8),
                _buildCustomersTable(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
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
        child: const Text(
          'Customers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomersTable() {
    if (customers.isEmpty) {
      return const Center(
        child: Text(
          'There are no customer records yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              return const Color(0xFF474C74);
            }),
            dataRowColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.grey.withOpacity(0.5);
              }
              return Colors.white;
            }),
            columns: const <DataColumn>[
              DataColumn(
                label: Expanded(
                  child: Text(
                    'ID',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Email',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            rows: customers.map((customer) {
              return DataRow(
                cells: [
                  DataCell(Text(customer.id.toString())),
                  DataCell(Text(customer.name)),
                  DataCell(Text(customer.email)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
