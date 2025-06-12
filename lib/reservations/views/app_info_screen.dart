import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/config/app_config.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? userInfo;
  String? hotelId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      String? token = await storage.read(key: 'token');
      String? storedHotelId = await storage.read(key: 'selected_hotel_id');
      
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userInfo = decodedToken;
          hotelId = storedHotelId;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppInfoCard(),
                  const SizedBox(height: 16),
                  _buildUserInfoCard(),
                  const SizedBox(height: 16),
                  _buildConfigurationCard(),
                  const SizedBox(height: 16),
                  _buildFeaturesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Smart Suite Mobile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Version: 1.0.0'),
            const Text('Hotel Management System'),
            const SizedBox(height: 8),
            const Text(
              'A comprehensive mobile application for hotel reservation management, built with Flutter.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (userInfo != null) ...[
              _buildInfoRow('Name', userInfo!['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? 'Not available'),
              _buildInfoRow('Role', userInfo!['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? 'Not available'),
              _buildInfoRow('User ID', userInfo!['sub'] ?? 'Not available'),
              _buildInfoRow('Email', userInfo!['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? 'Not available'),
            ] else
              const Text('No user information available'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),            const SizedBox(height: 12),
            _buildInfoRow('API Base URL', AppConfig.smartSuiteBaseUrl),
            _buildInfoRow('Current Hotel ID', hotelId ?? 'Not set'),
            _buildInfoRow('Token Status', userInfo != null ? 'Valid' : 'Invalid'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.featured_play_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Available Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('✓ Reservation Management', 'Create, view, and manage hotel reservations'),
            _buildFeatureItem('✓ Hotel Selection', 'Switch between different hotels'),
            _buildFeatureItem('✓ User Authentication', 'Secure login with JWT tokens'),
            _buildFeatureItem('✓ Real-time Updates', 'Live reservation status updates'),
            _buildFeatureItem('✓ Resource Booking', 'Book restaurants, rooms, and events'),
            _buildFeatureItem('✓ Customer Management', 'Handle customer information'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
