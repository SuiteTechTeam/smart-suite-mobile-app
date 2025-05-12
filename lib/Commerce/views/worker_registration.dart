import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Commerce/services/commerce_service.dart';
import 'package:sweetmanager/Communication/models/notification.dart';
import 'package:sweetmanager/Communication/services/notificationService.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class WorkerRegistration extends StatefulWidget {
   const WorkerRegistration({super.key, required this.workAreas, required this.adminId});

  final List<String> workAreas;

  final int adminId;

  @override
  State<WorkerRegistration> createState() => _WorkerRegistrationState();
}

class _WorkerRegistrationState extends State<WorkerRegistration> {

  // TextEditing Controller

  final _fullNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  final _dniController = TextEditingController();

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  final _authService = AuthService();

  final _notificationService = NotificationService();

  final _commerceService = CommerceService();

  int? _selectedWorkAreaId;

  @override
  void dispose() {

    _fullNameController.dispose();

    _emailController.dispose();

    _phoneNumberController.dispose();

    _dniController.dispose();

    _usernameController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  Future<String?> _getIdentity() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      role: '',
      childScreen: getContentView()
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Organization Registered Succesfully!'),
          content: const Text('The organization\'s set-up process has finished correctly.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return true to indicate success
              },
            ),
          ],
          icon: const Icon(Icons.add_home_sharp),
        );
      },
    );
  }

  Widget getContentView()
  {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back_login.png'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center( 
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Invite your First Worker",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 20),
                // Full Name Field
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Worker's Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Phone Number and DNI Fields (Side by Side)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dniController,
                        decoration: const InputDecoration(
                          labelText: "DNI",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: _selectedWorkAreaId,
                  items: widget.workAreas.asMap().entries.map((entry) {
                    int id = entry.key + 1; // ID starts at 1
                    String area = entry.value;
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(area),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkAreaId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Work Area',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Invite Button
                ElevatedButton(
                  onPressed: () async {
                    
                    String dni = _dniController.text;
                    String username = _usernameController.text;
                    String phoneNumber = _phoneNumberController.text;
                    String email = _emailController.text;
                    String name = _fullNameController.text;
                    String password = _passwordController.text;

                    if (phoneNumber.isEmpty || email.isEmpty || name.isEmpty || password.isEmpty || !name.contains(',')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all the corresponding fields following the requested instructions.')),
                      );
                      return;
                    }

                    List<String> parts = name.split(',');
                    name = parts[0].trim();
                    String surname = parts[1].trim();

                    username = '${name}_${surname}_${dni[0]}${dni[1]}${dni[2]}'.toLowerCase();

                    var validation = await _authService.signupWorker(int.parse(dni), username, name, surname, email, phoneNumber, password);

                    if (validation) {
                      String? ownersId = await _getIdentity();
                      var isNotificationCreated = await _notificationService.createNotification(Notifications(
                        1,
                        int.parse(ownersId!),
                        0,
                        int.parse(dni),
                        'Welcome to SweetManager!',
                        'Welcome to SweetManager! We’re thrilled to support your hotel management journey with streamlined operations, improved communication, and enhanced guest satisfaction. Let’s succeed together!',
                      ));

                      if (isNotificationCreated) {
                        // Now DateTime
                        String now = DateTime.now().toString().split(' ')[0];
                        // 4 month in future DateTime

                        String dueDate = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day).toString();

                        dueDate = dueDate.split(' ')[0];

                        var isAreaCreated = await _commerceService.registerAssignmentWorker(_selectedWorkAreaId!, int.parse(dni), widget.adminId, now, dueDate);

                        if(isAreaCreated)
                        {
                          // MODAL
                          _showSuccessDialog();

                          Navigator.pushNamed(context, '/dashboard');
                        }
                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please check the area registration')),
                          );
                          return;
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please check the notification registration')),
                        );
                        return;
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Couldn’t create admin.')),
                      );
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Invite"),
                ),
              ],
            ),
            )
          ),
        ),
        ],
      ), 
    );
  }
}