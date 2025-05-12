import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Communication/models/notification.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/Profiles/workers/services/workerservices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkerAddScreen extends StatefulWidget {
  const WorkerAddScreen({super.key});

  @override
  State<WorkerAddScreen> createState() => _WorkerAddScreenState();
}

class _WorkerAddScreenState extends State<WorkerAddScreen> {
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

  late Workerservice _workerService;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _workerService = Workerservice();
  }

  Future<String?> _getIdentity() async {
    String? token = await storage.read(key: 'token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }

  Future<void> _addWorker() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> newWorker = {
        'id': _idController.text.isNotEmpty ? int.parse(_idController.text) : null,
        'username': _usernameController.text,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'phone': int.parse(_phoneController.text),
        'state': _stateController.text,
        'password': _passwordController.text,
      };

      final response = await _workerService.createWorker(newWorker);

      String? ownersId = await _getIdentity();

      int workerId = int.parse(_idController.text);

      // Crear la notificación
      var isNotificationCreated = await _notificationService.createNotification(Notifications(
        1, // Tipo de notificación
        int.parse(ownersId!), // OwnerId
        0, // AdminId desde el token
        workerId, // WorkerId desde el input
        'Welcome to SweetManager!', // Título
        'Welcome to SweetManager! We’re thrilled to support your hotel management journey with streamlined operations, improved communication, and enhanced guest satisfaction. Let’s succeed together!', // Descripción
      ));

      // Comprobar si la notificación fue creada
      if (isNotificationCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker added and notification sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create notification!')),
        );
      }

      print('Worker added response: $response');
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add worker: $e')),
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
      resizeToAvoidBottomInset: true, // Evita el overflow cuando se muestra el teclado
      body: SingleChildScrollView(
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
                    'Add Worker',
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
                        controller: _idController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.key),
                          labelText: 'Worker ID',
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
                            onPressed: _addWorker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF474C74),
                            ),
                            child: const Text(
                              'Add Worker',
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
}
