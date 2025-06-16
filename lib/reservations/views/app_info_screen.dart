import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';  // For date formatting
import '../../core/config/app_config.dart';
import '../../iam/services/auth_service.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userInfo;
  Map<String, dynamic>? jwtClaims;
  String? hotelId;
  bool isLoading = true;
  bool isTokenExpired = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      String? token = await _authService.getToken();
      String? storedHotelId = await storage.read(key: 'selected_hotel_id');
      
      if (token != null) {
        // Decode the full JWT for display
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        
        // Check if token is valid and not expired
        bool tokenExpired = JwtDecoder.isExpired(token);
        
        // Get simplified user info from AuthService
        Map<String, dynamic>? simplifiedInfo = await _authService.getUserInfo();
        
        setState(() {
          jwtClaims = decodedToken;
          userInfo = simplifiedInfo;
          hotelId = storedHotelId;
          isTokenExpired = tokenExpired;
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
  // Helper method to format role names for better readability
  String formatRoleName(String? roleName) {
    if (roleName == null || roleName.isEmpty) return 'Not available';
    
    // Handle ROLE_ prefix commonly used in JWT role claims
    if (roleName.startsWith('ROLE_')) {
      String cleaned = roleName.substring(5); // Remove 'ROLE_' prefix
      return cleaned.substring(0, 1).toUpperCase() + cleaned.substring(1).toLowerCase();
    }
    
    // Standard capitalization for other roles
    return roleName.substring(0, 1).toUpperCase() + roleName.substring(1).toLowerCase();
  }

  // Helper method to format JWT timestamp claims
  String _formatExpiration(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      // JWT timestamps are in seconds since epoch
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      
      // Format with intl package
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return 'Invalid date format';
    }
  }

  // Helper method to build section headers for user info card
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  // Helper method to format claim values for display
  String _formatClaimValue(dynamic value) {
    if (value == null) return 'null';
    
    // Handle timestamps (exp, iat, nbf)
    if (value is num && 
        (jwtClaims!.keys.contains('exp') && 
         value.toString() == jwtClaims!['exp'].toString() ||
         jwtClaims!.keys.contains('iat') && 
         value.toString() == jwtClaims!['iat'].toString() ||
         jwtClaims!.keys.contains('nbf') && 
         value.toString() == jwtClaims!['nbf'].toString())) {
      return _formatExpiration(value);
    }
    
    // Handle arrays/lists
    if (value is List) {
      return value.join(', ');
    }
    
    // Handle other values
    return value.toString();
  }

  // Mapa para nombres amigables de claims JWT
  Map<String, String> get claimNameMap => {
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid': 'User ID (SID)',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': 'Role',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality': 'Hotel ID (Locality)',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress': 'Email Address',
    'Email': 'Email (Simple)',
    'UserId': 'User ID (Simple)',
    'exp': 'Token Expiration',
    'iss': 'Token Issuer',
    'aud': 'Audience',
  };
  
  // Método para obtener nombre amigable de un claim
  String getFriendlyClaimName(String claimKey) {
    return claimNameMap[claimKey] ?? claimKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
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
    bool isTokenValid = jwtClaims != null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isTokenValid ? (isTokenExpired ? Icons.person_off : Icons.person) : Icons.person_off,
                  color: isTokenValid ? (isTokenExpired ? Colors.orange : Theme.of(context).primaryColor) : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isTokenValid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTokenExpired ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isTokenExpired ? 'Token Expired' : 'Token Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: isTokenExpired ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
              ],
            ),
            const Divider(),
            
            if (userInfo != null) ...[
              // User Identity Section
              _buildSectionHeader('User Identity'),
              _buildInfoRow('User ID', userInfo!['id']?.toString() ?? 'Not available'),
              _buildInfoRow('Email', userInfo!['email'] ?? 'Not available'),
              
              const SizedBox(height: 12),
              
              // Access Control Section
              _buildSectionHeader('Access Control'),
              _buildInfoRow('Role', formatRoleName(userInfo!['role'])),
              _buildInfoRow('Hotel ID', userInfo!['hotelId']?.toString() ?? 'Not available'),
              
              if (jwtClaims != null) ...[
                const SizedBox(height: 16),
                
                // Token Information Section
                _buildSectionHeader('Token Information'),
                _buildInfoRow('Issued At', jwtClaims!['iat'] != null ? _formatExpiration(jwtClaims!['iat']) : 'Unknown'),
                _buildInfoRow('Expires At', jwtClaims!['exp'] != null ? _formatExpiration(jwtClaims!['exp']) : 'Unknown'),
                _buildInfoRow('Issuer', jwtClaims!['iss']?.toString() ?? 'Unknown'),
                _buildInfoRow('Audience', jwtClaims!['aud']?.toString() ?? 'Unknown'),
                
                const SizedBox(height: 16),
                
                // Raw Claims Section
                ExpansionTile(
                  title: const Text(
                    'All JWT Claims',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    ...jwtClaims!.entries.map((entry) => _buildInfoRow(
                      getFriendlyClaimName(entry.key),
                      _formatClaimValue(entry.value),
                    )).toList(),
                  ],
                ),
              ],
            ] else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No user information available.\nPlease log in first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
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
            ),
            const Divider(),
            _buildInfoRow('API Base URL', AppConfig.smartSuiteBaseUrl),
            _buildInfoRow('Current Hotel ID', hotelId ?? 'Not set'),
            if (jwtClaims != null) ...[
              _buildInfoRow('Authentication', 'JWT Bearer Token'),
            ] else ...[
              _buildInfoRow('Authentication', 'Not authenticated'),
            ],
            _buildInfoRow('App Environment', AppConfig.environment),
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
