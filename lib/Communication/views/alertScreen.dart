import 'package:flutter/material.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import '../models/notification.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'writeAlert.dart'; // Import WriteAlertScreen

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Notifications> alertNotifications = []; // List of fetched alert notifications
  bool isLoading = true;
  late NotificationService notificationService;
  final storage = const FlutterSecureStorage();
  String? role;
  int? hotelId; // Added hotelId to fetch alerts

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _loadHotelId(); // Load the hotel ID on initialization
  }

  Future<String?> _getRole() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
    }
    return null;
  }

  Future<void> _loadHotelId() async {
    hotelId = await _getHotelId(); // Fetch the hotel ID
    if (hotelId != null) {
      fetchAlertNotifications(); // Fetch notifications if hotel ID is available
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
    }
  }

  Future<int?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    if (token == null || JwtDecoder.isExpired(token)) {
      return null; // Token is missing or expired
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    if (decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'] != null) {
      try {
        return int.parse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']);
      } catch (e) {
        print('Failed to convert Hotel ID: $e');
      }
    }
    return null;
  }

  Future<void> fetchAlertNotifications() async {
    if (hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel ID not found')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Fetching all notifications using the hotel ID
      final notifications = await notificationService.getAllNotifications(hotelId!);

      // Filter the notifications to only include those with typesNotificationsId == 2
      alertNotifications = notifications.where((notification) => notification.typesNotificationsId == 2).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
      print("Error fetching notifications: $e");
    }
  }

  void removeNotification(int index) {
    setState(() {
      alertNotifications.removeAt(index);
    });
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
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteAlertScreen()),
                      );
                      if (result == true) {
                        fetchAlertNotifications(); // Reload alerts if a new alert was created
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5282),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Write Alert',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator()) // Show a loading spinner
                      : Expanded(
                    child: ListView.builder(
                      itemCount: alertNotifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          notification: alertNotifications[index],
                          index: index,
                          removeNotification: removeNotification,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Notifications notification;
  final int index;
  final Function(int) removeNotification;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.index,
    required this.removeNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.notification_important, color: Colors.red),
        title: Text(
          notification.title!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification.description!),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => removeNotification(index),
        ),
      ),
    );
  }
}