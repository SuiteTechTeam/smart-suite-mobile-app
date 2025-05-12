import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Commerce/views/room_types_setup.dart';
import 'package:sweetmanager/Profiles/hotels/models/hotel.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  HotelDetailScreen({Key? key, required this.hotel}) : super(key: key);

  // Inicializando el almacenamiento seguro
  final storage = const FlutterSecureStorage();

  Future<String?> _getRole() async {
    // Recuperar el token del almacenamiento local
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    }

    return null; // Retornar null si no se encuentra el token
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          String? role = snapshot.data;

          // Verificar si el rol es 'ROLE_OWNER'
          if (role != 'ROLE_OWNER') {
            return const Center(child: Text('Access denied. You do not have permission to view this page.'));
          }

          return BaseLayout(
            role: role!,
            childScreen: _buildHotelDetailPage(context),
          );
        }

        return const Center(child: Text('Unable to retrieve role'));
      },
    );
  }

  Widget _buildHotelDetailPage(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://i.pinimg.com/564x/29/1b/10/291b104087960aa6b0c63e1aca8a7977.jpg',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    hotel.name!, // Usar el nombre del hotel
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        hotel.address!, // Usar la dirección del hotel
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOTEL INFO',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildHotelInfoRow('Name', hotel.name!),
                  _buildHotelInfoRow('Address', hotel.address!),
                  _buildHotelInfoRow('Phone Number', hotel.phoneNumber!.toString()),
                  _buildHotelInfoRow('Email', hotel.email!),
                  _buildHotelInfoRow('Owner ID', hotel.ownerId.toString()),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hotel.description!, // Usar la descripción del hotel
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción de guardar

                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomTypesSetup()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1C4257),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
