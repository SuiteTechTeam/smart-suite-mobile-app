import 'package:flutter/material.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/Communication/views/writeMessage.dart';
import '../models/notification.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart';
import '../components/notificationCard.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  int? hotelId;
  bool isLoading = true;
  List<Notifications> notifications = [];
  List<Notifications> _messages = []; // Define _messages
  List<Notifications> _filteredMessages = []; // Define _filteredMessages

  late NotificationService notificationService;
  final storage = const FlutterSecureStorage();
  String? role;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    notificationService = NotificationService();
    _loadHotelId();
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

    if (token == null || JwtDecoder.isExpired(token)) {
      print('Token is missing or expired.');
      return null;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    if (decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'] != null) {
      try {
        return int.parse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']);
      } catch (e) {
        print('Failed to Convert Hotel ID $e');
      }
    }
    print('Hotel ID not found');
    return null;
  }

  Future<void> _loadHotelId() async {
    int? tokenHotelId = await _getHotelId();
    print('Hotel ID: $tokenHotelId');

    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      fetchNotifications(); // Asegúrate de que fetchNotifications esté implementada
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel ID not found')),
        );
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch notifications from the backend
  Future<void> fetchNotifications() async {
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
      final fetchedNotifications = await notificationService.getAllNotifications(hotelId!); // Fetch notifications using hotelId
      setState(() {
        notifications = fetchedNotifications; // Assign fetched notifications to the list
        _messages = fetchedNotifications; // Assign to _messages
        _filteredMessages = fetchedNotifications; // Assign to _filteredMessages
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

  // Fetch messages from the backend
  Future<void> fetchMessages() async {
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
      final fetchedMessages = await notificationService.getMessages(hotelId!); // Fetch messages using hotelId
      setState(() {
        _messages = fetchedMessages; // Update _messages with fetched messages
        _filteredMessages = fetchedMessages; // Update _filteredMessages with fetched messages
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
      print("Error fetching messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 12.0),
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      ElevatedButton(onPressed: (){
                        
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WriteMessage()));

                      },child: const Text('NEW'))
                    ],
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: notifications.length, // Use notifications here
                      itemBuilder: (context, index) {
                        return NotificationCard(notification: notifications[index]);
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
