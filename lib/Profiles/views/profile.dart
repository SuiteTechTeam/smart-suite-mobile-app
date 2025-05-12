  import 'package:flutter/material.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:jwt_decoder/jwt_decoder.dart';
  import 'package:sweetmanager/Shared/widgets/base_layout.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  class ProfilePage extends StatefulWidget {
    ProfilePage({Key? key}) : super(key: key);

    @override
    _ProfilePageState createState() => _ProfilePageState();
  }

  class _ProfilePageState extends State<ProfilePage> {
    final storage = const FlutterSecureStorage();
    final String baseUrl = 'https://sweetmanager-api.ryzeon.me';
    bool _isPasswordVisible = false; // Estado para la visibilidad de la contraseña
    String? _realPassword ;  // Estado para la visibilidad de la contraseña

    Future<String?> _getIdentity() async {
      try {
        String? token = await storage.read(key: 'token');
        if (token == null) return null;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        var id = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid'];
        if (id != null) {
          // Asegurarse de que el ID sea una cadena
          return id.toString();
        }
        return null;
      } catch (e) {
        print('Error getting identity: $e');
        return null;
      }
    }

    Future<String?> _getLocality() async {
      try {
        String? token = await storage.read(key: 'token');
        if (token == null) return null;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String? locality = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();
        print('Locality: $locality');
        return locality;
      } catch (e) {
        print('Error getting locality: $e');
        return null;
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

    Future<Map<String, dynamic>> _getUserInfo() async {
      try {
        String? identity = await _getIdentity();
        String? role = await _getRole();
        String? locality = await _getLocality();
        String? token = await storage.read(key: 'token');

        print('Identity: $identity');
        print('Role: $role');
        print('Locality: $locality');

        if (identity == null || role == null || token == null) {
          throw Exception('Missing required information');
        }

        // Manejar el rol OWNER directamente
        if (role == 'ROLE_OWNER') {
          return {
            'role': role,
            'name': 'MAURI', // Nombre actualizado
            'surname': 'WIWI', // Apellido actualizado
            'username': 'mauri_wiwi_777', // Usuario actualizado
            'email': 'mau@gmail.com', // Correo actualizado
            'phone': '941691025', // Teléfono actualizado
          };
        }

        // Seleccionar el endpoint correcto según el rol
        String endpoint;
        switch (role) {
          case 'ROLE_ADMIN':
            endpoint = '/api/v1/user/get-all-admins';
            break;
          case 'ROLE_WORKER':
            endpoint = '/api/v1/user/get-all-workers';
            break;
          default:
            throw Exception('Unknown role: $role');
        }

        final response = await http.get(
          Uri.parse('$baseUrl$endpoint?hotelId=$locality'),
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          List<dynamic> users = json.decode(response.body);

          // Imprimir todos los IDs para debug
          print('Available IDs: ${users.map((user) => user['id']).toList()}');
          print('Looking for ID: $identity');

          // Buscar el usuario actual
          Map<String, dynamic>? currentUser;
          try {
            currentUser = users.firstWhere(
                  (user) {
                // Convertir ambos valores a String para la comparación
                String userId = user['id'].toString();
                print('Comparing user ID: $userId with identity: $identity');
                return userId == identity;
              },
            );
          } catch (e) {
            print('User not found: $e');
            currentUser = null;
          }

          if (currentUser != null) {
            return {
              'role': role,
              'name': currentUser['name']?.toString() ?? 'N/A',
              'username': currentUser['username']?.toString() ?? 'N/A',
              'email': currentUser['email']?.toString() ?? 'N/A',
              'phone': currentUser['phone']?.toString() ?? 'N/A',
            };
          } else {
            throw Exception('User not found in the list');
          }
        } else {
          throw Exception('Failed to load user info. Status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error in _getUserInfo: $e');
        rethrow;
      }
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            Map<String, dynamic> userInfo = snapshot.data as Map<String, dynamic>;
            return BaseLayout(
              role: userInfo['role'],
              childScreen: _buildProfilePage(userInfo),
            );
          }

          return const Center(child: Text('No user information available'));
        },
      );
    }

    Widget _buildProfilePage(Map<String, dynamic> userInfo) {
      // Verificar si el rol es OWNER
      if (userInfo['role'] == 'ROLE_OWNER') {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner Name: MAURI WIWI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Owner Email: mau@gmail.com',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildInfoField('Business Name', 'Sweet Manager Inc.'),
                  buildInfoField('Location', '123 Sweet St, Candyland'),
                  buildInfoField('Contact Number', '(123) 456-7890'),
                  buildInfoField('Total Employees', '50'),
                  buildInfoField('Supervision Areas', 'All Areas'),
                  SizedBox(height: 20),
                  buildPasswordField(),
                ],
              ),
            ),
          ),
        );
      }

      // Si no es OWNER, mostrar la vista normal
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo['name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                buildEditableField('Name', userInfo['name'] ?? 'N/A', 'Change name'),
                buildEditableField('Username', userInfo['username'] ?? 'N/A', 'Change username'),
                buildEditableField('Email', userInfo['email'] ?? 'N/A', 'Change email'),
                buildEditableField('Phone', userInfo['phone'] ?? 'N/A', 'Change phone'),

                if (userInfo['role'] == 'ROLE_WORKER')
                  buildInfoField('Assigned Area', 'SECURITY STAFF'),

                buildPasswordField(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildEditableField(String label, String value, String actionLabel) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextFormField(
              readOnly: true,
              initialValue: value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Acción para cambiar el valor
                },
                child: Text(
                  actionLabel,
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildPasswordField() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextFormField(
              obscureText: !_isPasswordVisible, // Controla si la contraseña está visible u oculta
              initialValue: _isPasswordVisible ? _realPassword : '********', // Muestra la contraseña real o un asterisco
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Alterna la visibilidad
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Acción para cambiar la contraseña
                  print("Change password pressed.");
                },
                child: Text(
                  'Change password',
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ),
          ],
        ),
      );
    }


    Widget buildInfoField(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextFormField(
              readOnly: true,
              initialValue: value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
