import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Communication/models/notification.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/Profiles/admins/services/adminservices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminAddScreen extends StatefulWidget {
  const AdminAddScreen({super.key});

  @override
  State<AdminAddScreen> createState() => _AdminAddScreenState();
}

class _AdminAddScreenState extends State<AdminAddScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _notificationService = NotificationService();

  bool isLoading = false;

  late AdminService _adminService;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _adminService = AdminService();
  }

  Future<void> _addAdmin() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> newAdmin = {
        'id': _idController.text.isNotEmpty ? int.parse(_idController.text) : null,
        'username': _usernameController.text,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'phone': int.parse(_phoneController.text),
        'state': _stateController.text,
        'password': _passwordController.text,
      };

      final response = await _adminService.createAdmin(newAdmin);

      String? ownersId = await _getIdentity();

      int adminId = int.parse(_idController.text);

      // Crear la notificación
      var isNotificationCreated = await _notificationService.createNotification(Notifications(
        1, // Tipo de notificación
        int.parse(ownersId!), // OwnerId
        adminId, // AdminId desde el input
        0, // workersId (puedes cambiarlo si lo necesitas)
        'Welcome to SweetManager!', // Título
        'Welcome to SweetManager! We’re thrilled to support your hotel management journey with streamlined operations, improved communication, and enhanced guest satisfaction. Let’s succeed together!', // Descripción
      ));

      // Comprobar si la notificación fue creada
      if (isNotificationCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin added and notification sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create notification!')),
        );
      }

      // Regresar a la pantalla anterior
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add admin: $e')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF474C74),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _idController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.key),
                              labelText: 'ID',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person),
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.badge),
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.badge_outlined),
                              labelText: 'Surname',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.phone),
                              labelText: 'Phone',
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
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                onPressed: _addAdmin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF474C74),
                                ),
                                child: const Text(
                                  'Add Admin',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _getIdentity() async {
    String? token = await storage.read(key: 'token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }
}
