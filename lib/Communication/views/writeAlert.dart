import 'package:flutter/material.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart'; // Import AuthService for token management
import '../models/notification.dart';

class WriteAlertScreen extends StatefulWidget {
  @override
  _WriteAlertScreenState createState() => _WriteAlertScreenState();
}

class _WriteAlertScreenState extends State<WriteAlertScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers to capture form values
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _workerIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    final authService = AuthService(); // Instantiate AuthService
    notificationService = NotificationService();
  }

  // Submit the alert notification
  Future<void> _submitNotification() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Convert form values to int for IDs
      int ownersId = int.tryParse(_ownerIdController.text) ?? 0;
      int adminsId = int.tryParse(_adminIdController.text) ?? 0;
      int workersId = int.tryParse(_workerIdController.text) ?? 0;

      // Create a new notification instance
      Notifications newNotification = Notifications(
        2, // typesNotificationsId for alerts
        ownersId,
        adminsId,
        workersId,
        _titleController.text,
        _descriptionController.text, // Description of the notification
      );

      try {
        // Call the service to send the alert
        bool success = await notificationService.createAlert(newNotification);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alert sent successfully!')),
          );
          // Clear form fields after submission
          _ownerIdController.clear();
          _adminIdController.clear();
          _workerIdController.clear();
          _titleController.clear();
          _descriptionController.clear();
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send alert: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTER ALERT'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Owner ID:'),
              _buildTextField(
                  hintText: 'Enter owner ID',
                  controller: _ownerIdController,
                  icon: Icons.person),
              const SizedBox(height: 16),
              _buildLabel('Admin ID:'),
              _buildTextField(
                  hintText: 'Enter admin ID',
                  controller: _adminIdController,
                  icon: Icons.admin_panel_settings),
              const SizedBox(height: 16),
              _buildLabel('Worker ID:'),
              _buildTextField(
                  hintText: 'Enter worker ID',
                  controller: _workerIdController,
                  icon: Icons.people),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitNotification,
                  child: const Text('Send',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.black,
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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