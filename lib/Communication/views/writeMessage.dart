// writeMessage.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/Profiles/hotels/models/hotel.dart';
import 'package:sweetmanager/Profiles/hotels/service/hotelservices.dart';
import '../models/notification.dart';
import 'messageScreen.dart'; // Import MessagesScreen

class WriteMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ComposeMessage(),
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(background: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class ComposeMessage extends StatefulWidget {
  @override
  _ComposeMessageState createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeMessage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers to capture form values
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late NotificationService notificationService;

  final storage = const FlutterSecureStorage();

  String? role;

  final hotelService = HotelService();


  @override
  void initState() {
    super.initState();
    
    notificationService = NotificationService();
  }

  Future<String?> _getLocality() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();
  }

  // Submit the message notification
  Future<void> _submitMessage() async {
    if (_formKey.currentState?.validate() ?? false) {

      if(role == 'ROLE_ADMIN')
      {
        // Set typesNotificationsId to 1 by default
        List<Hotel> hotels = await hotelService.fetchHotels();

        String? hotelId = await _getLocality();

        var hotel = hotels.firstWhere((h)=> h.id == int.parse(hotelId!));

        int typesNotificationsId = 1;
        int ownersId = hotel.ownerId!;
        String? adminsId = await _getIdentity();
        int workersId = 0;

        // Create a new notification instance
        Notifications newMessage = Notifications(
          typesNotificationsId,
          ownersId,
          int.parse(adminsId!),
          workersId,
          _titleController.text,
          _descriptionController.text, // Description of the notification
        );

        try {
          // Call the service to send the message
          bool success = await notificationService.createNotification(newMessage);
          if (success) {
            _showSuccessDialogAdmin();
            // Clear form fields after submission
            _fromController.clear();
            _subjectController.clear();
            _messageController.clear();
            _titleController.clear();
            _descriptionController.clear();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      }
      else
      {
        int typesNotificationsId = 1;
        String? ownersId = await _getIdentity();
        int adminsId = 0;
        int workersId = 0;

        // Create a new notification instance
        Notifications newMessage = Notifications(
          typesNotificationsId,
          int.parse(ownersId!),
          adminsId,
          workersId,
          _titleController.text,
          _descriptionController.text, // Description of the notification
        );

        try {
          // Call the service to send the message
          bool success = await notificationService.createNotification(newMessage);
          if (success) {
            _showSuccessDialogOwner();
            // Clear form fields after submission
            _fromController.clear();
            _subjectController.clear();
            _messageController.clear();
            _titleController.clear();
            _descriptionController.clear();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      }
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

  void _showSuccessDialogOwner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Sended'),
          content: const Text('Your message has been sended to admins succesfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return true to indicate success
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialogAdmin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Sended'),
          content: const Text('Your message has been sended to workers succesfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return true to indicate success
              },
            ),
          ],
        );
      },
    );
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
    return FutureBuilder(
      future: _getRole(), 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        role = snapshot.data;

        return getContentView(role!);
      }
    
    );
  }

  Widget getContentView(String role){
    if(role == 'ROLE_OWNER')
    {
      // THIS MESSAGE WILL BE SENDED TO ALL ADMINS
      return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MessagesScreen()),
            );
          },
        ),
        title: const Text(
          'Send Message to all Admins',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Title:'),
              _buildTextField(
                  hintText: 'Enter title',
                  controller: _titleController,
                  icon: Icons.title),
              const SizedBox(height: 16),
              _buildLabel('Description:'),
              _buildTextField(
                  hintText: 'Enter description',
                  controller: _descriptionController,
                  icon: Icons.description),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _submitMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
    else
    {
      // THIS MESSAGE WILL BE SENDED TO ALL WORKERS
      return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MessagesScreen()),
            );
          },
        ),
        title: const Text(
          'Send Message to Workers',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Title:'),
              _buildTextField(
                  hintText: 'Enter title',
                  controller: _titleController,
                  icon: Icons.title),
              const SizedBox(height: 16),
              _buildLabel('Description:'),
              _buildTextField(
                  hintText: 'Enter description',
                  controller: _descriptionController,
                  icon: Icons.description),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _submitMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
      {required String hintText,
        required TextEditingController controller,
        required IconData icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}