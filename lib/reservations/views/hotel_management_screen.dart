import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/hotel_service.dart';

class HotelManagementScreen extends StatefulWidget {
  const HotelManagementScreen({super.key});

  @override
  State<HotelManagementScreen> createState() => _HotelManagementScreenState();
}

class _HotelManagementScreenState extends State<HotelManagementScreen> {
  late HotelService _hotelService;
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> hotels = [];
  bool isLoading = true;
  String? userRole;
  int? userId;

  @override
  void initState() {
    super.initState();
    _hotelService = HotelService();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      String? token = await storage.read(key: 'token');
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userRole = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          userId = int.tryParse(decodedToken['sub'] ?? '');
        });
        await _loadHotels();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error loading user information: $e');
    }
  }

  Future<void> _loadHotels() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> fetchedHotels;
      
      // If user is an owner, load their hotels; otherwise load all hotels
      if (userRole?.toLowerCase() == 'owner' && userId != null) {
        fetchedHotels = await _hotelService.getHotelsByOwnerId(userId!);
      } else {
        fetchedHotels = await _hotelService.getAllHotels();
      }

      setState(() {
        hotels = fetchedHotels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Failed to load hotels: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHotels,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotels.isEmpty
              ? const Center(
                  child: Text(
                    'No hotels found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return _buildHotelCard(hotel);
                  },
                ),
      floatingActionButton: userRole?.toLowerCase() == 'owner'
          ? FloatingActionButton(
              onPressed: _showCreateHotelDialog,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hotel,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotel['name'] ?? 'Unknown Hotel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ID: ${hotel['id']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, hotel['address'] ?? 'No address'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, hotel['phone'] ?? 'No phone'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, hotel['email'] ?? 'No email'),
            if (userRole?.toLowerCase() == 'owner') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showUpdateHotelDialog(hotel),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _selectHotel(hotel['id']),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Select'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _selectHotel(hotel['id']),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Select Hotel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _selectHotel(int hotelId) async {
    await storage.write(key: 'selected_hotel_id', value: hotelId.toString());
    _showSnackBar('Hotel selected: ID $hotelId');
    if (mounted) {
      Navigator.pop(context, true); // Return to previous screen with success result
    }
  }

  void _showCreateHotelDialog() {
    _showHotelDialog();
  }

  void _showUpdateHotelDialog(Map<String, dynamic> hotel) {
    _showHotelDialog(existingHotel: hotel);
  }

  void _showHotelDialog({Map<String, dynamic>? existingHotel}) {
    final nameController = TextEditingController(text: existingHotel?['name'] ?? '');
    final addressController = TextEditingController(text: existingHotel?['address'] ?? '');
    final phoneController = TextEditingController(text: existingHotel?['phone'] ?? '');
    final emailController = TextEditingController(text: existingHotel?['email'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingHotel != null ? 'Update Hotel' : 'Create Hotel'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hotel Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hotel name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _saveHotel(
                    existingHotel: existingHotel,
                    name: nameController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  );
                }
              },
              child: Text(existingHotel != null ? 'Update' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveHotel({
    Map<String, dynamic>? existingHotel,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      if (existingHotel != null) {
        // Update existing hotel
        await _hotelService.updateHotel(
          hotelId: existingHotel['id'],
          name: name,
          address: address,
          phone: phone,
          email: email,
        );
        _showSnackBar('Hotel updated successfully');
      } else {
        // Create new hotel
        await _hotelService.createHotel(
          name: name,
          address: address,
          phone: phone,
          email: email,
        );
        _showSnackBar('Hotel created successfully');
      }
      await _loadHotels();
    } catch (e) {
      _showSnackBar('Failed to save hotel: $e');
    }
  }
}
