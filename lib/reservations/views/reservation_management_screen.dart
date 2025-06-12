import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../../hotels/services/hotel_service.dart';
import '../../iam/services/auth_service.dart';
import 'add_reservation_screen.dart';
import 'reservation_detail_screen.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  State<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends State<ReservationManagementScreen> {
  late ReservationService _reservationService;
  late HotelService _hotelService;
  late AuthService _authService;
  static const storage = FlutterSecureStorage();
  
  List<Reservation> reservations = [];
  bool isLoading = true;
  int? hotelId;
  String? role;
  String? hotelName;
  String selectedFilter = 'all'; // 'all', 'pending', 'confirmed', 'cancelled'

  @override
  void initState() {
    super.initState();
    _reservationService = ReservationService();
    _hotelService = HotelService();
    _authService = AuthService();
    _loadHotelId();
  }

  Future<String?> _getRole() async {
    return await _authService.getUserRole();
  }

  Future<int?> _getHotelId() async {
    return await _authService.getHotelIdFromToken();
  }

  Future<void> _loadHotelId() async {
    // First try to get hotel ID from JWT token
    int? tokenHotelId = await _getHotelId();
    if (tokenHotelId != null) {
      if (mounted) {
        setState(() {
          hotelId = tokenHotelId;
        });
      }
      await _fetchReservations();
      return;
    }
      
    // If not in token, try to get from stored preferences
    int? storedHotelId = await _getStoredHotelId();
    if (storedHotelId != null) {
      if (mounted) {
        setState(() {
          hotelId = storedHotelId;
        });
      }
      await _fetchReservations();
      return;
    }
    
    // If no hotel ID found anywhere, show dialog
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    _showHotelIdDialog();
  }

  Future<void> _fetchReservations() async {
    if (hotelId == null) return;
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      // Use the updated ReservationService method (now uses /api/booking/get-all-bookings)
      List<Reservation> fetchedReservations = await _reservationService.getReservationsByHotelId(hotelId!);
      if (mounted) {
        setState(() {
          reservations = fetchedReservations;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  List<Reservation> get filteredReservations {
    if (selectedFilter == 'all') {
      return reservations;
    }
    return reservations.where((reservation) => reservation.state == selectedFilter).toList();
  }

  Future<void> _addReservation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReservationScreen()),
    );

    if (result == true) {
      await _fetchReservations();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showHotelIdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hotel ID Required'),
          content: const Text(
            'No hotel ID was found in your account. Please enter a hotel ID to continue, or use a default one for testing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAvailableHotelsDialog();
              },
              child: const Text('Browse Hotels'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showHotelIdInputDialog();
              },
              child: const Text('Enter Hotel ID'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _useDefaultHotelId();
              },
              child: const Text('Use Default (1)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showHotelIdInputDialog() {
    TextEditingController hotelIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Hotel ID'),
          content: TextField(
            controller: hotelIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Hotel ID',
              hintText: 'Enter your hotel ID (e.g., 1)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String inputText = hotelIdController.text.trim();
                if (inputText.isNotEmpty) {
                  int? inputHotelId = int.tryParse(inputText);
                  if (inputHotelId != null && inputHotelId > 0) {
                    Navigator.of(context).pop();
                    _setHotelId(inputHotelId);
                  } else {
                    _showSnackBar('Please enter a valid hotel ID');
                  }
                } else {
                  _showSnackBar('Please enter a hotel ID');
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _useDefaultHotelId() {
    _setHotelId(1); // Default hotel ID for testing
  }

  void _setHotelId(int newHotelId) async {
    if (mounted) {
      setState(() {
        hotelId = newHotelId;
        isLoading = true;
        hotelName = null;
      });
    }
    try {
      final hotelData = await _hotelService.getHotelById(newHotelId);
      if (hotelData != null) {
        if (mounted) {
          setState(() {
            hotelName = hotelData.name;
          });
        }
        await storage.write(key: 'selected_hotel_id', value: newHotelId.toString());
        if (mounted) {
          _showSnackBar('Connected to hotel: ${hotelName ?? 'ID $newHotelId'}');
        }
        await _fetchReservations();
      } else {
        if (mounted) {
          setState(() {
            hotelName = 'Test Hotel (ID: $newHotelId)';
            isLoading = false;
          });
        }
        await storage.write(key: 'selected_hotel_id', value: newHotelId.toString());
        if (mounted) {
          _showSnackBar('Hotel ID $newHotelId not found on server. Using for testing.');
        }
        await _fetchReservations();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hotelName = 'Error loading hotel';
          isLoading = false;
        });
        _showSnackBar('Error connecting to hotel.');
      }
    }
  }

  // Check if there's a previously stored hotel ID
  Future<int?> _getStoredHotelId() async {
    String? storedHotelId = await storage.read(key: 'selected_hotel_id');
    return storedHotelId != null ? int.tryParse(storedHotelId) : null;
  }

  // Method to show available hotels
  void _showAvailableHotelsDialog() async {
    try {
      final hotels = await _hotelService.getAllHotels();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Hotel'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: hotels.isEmpty
                    ? const Center(child: Text('No hotels available'))
                    : ListView.builder(
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          return ListTile(
                            title: Text(hotel.name),
                            subtitle: Text('ID: ${hotel.id} - ${hotel.address}'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _setHotelId(hotel.id);
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showHotelIdInputDialog();
                  },
                  child: const Text('Enter Manually'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      _showSnackBar('Failed to load hotels: $e');
      _showHotelIdInputDialog(); // Fallback to manual input
    }
  }
  // Utility methods for formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == tomorrow) {
      return 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
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
        
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reservations Management'),
                if (hotelId != null)
                  Text(
                    hotelName != null ? hotelName! : 'Hotel ID: $hotelId',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: isLoading ? null : _fetchReservations,
                tooltip: 'Refresh reservations',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showHotelIdDialog(),
                tooltip: 'Change hotel',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildHeader(),
              if (!isLoading && reservations.isNotEmpty) _buildReservationStats(),
              _buildFilterChips(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildReservationsList(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addReservation,
            backgroundColor: const Color(0xFF474C74),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Reservations Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Total: ${filteredReservations.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Confirmed', 'confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == value,
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF474C74).withValues(alpha: 0.3),
      checkmarkColor: const Color(0xFF474C74),
    );
  }

  Widget _buildReservationsList() {
    if (filteredReservations.isEmpty) {
      return const Center(
        child: Text(
          'No reservations found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredReservations.length,
      itemBuilder: (context, index) {
        final reservation = filteredReservations[index];
        return _buildReservationCard(reservation);
      },
    );
  }

  // UI overflow fixes applied
  Widget _buildReservationCard(Reservation reservation) {
    Color statusColor;
    IconData statusIcon;

    switch (reservation.state) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          statusIcon,
          color: statusColor,
          size: 32,
        ),        title: Text(
          'Room Booking #${reservation.id ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room ${reservation.roomId} • ${_formatDate(reservation.startDate)} - ${_formatDate(reservation.finalDate)}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Nights: ${reservation.nightCount} • \$${reservation.amount.toStringAsFixed(2)}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [              Flexible(
                child: Text(
                  reservation.state.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationDetailScreen(reservation: reservation),
            ),
          ).then((_) => _fetchReservations());
        },
      ),
    );
  }

  // Add reservation statistics widget
  Widget _buildReservationStats() {
    if (reservations.isEmpty) return const SizedBox.shrink();

    final totalReservations = reservations.length;    final confirmedCount = reservations.where((r) => r.state == 'confirmed').length;
    final pendingCount = reservations.where((r) => r.state == 'pending').length;
    final cancelledCount = reservations.where((r) => r.state == 'cancelled').length;
    final totalRevenue = reservations
        .where((r) => r.state == 'confirmed')
        .fold(0.0, (sum, r) => sum + r.amount);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total', totalReservations.toString(), Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('Confirmed', confirmedCount.toString(), Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
                ),
                Expanded(
                  child: _buildStatItem('Cancelled', cancelledCount.toString(), Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Total Revenue (Confirmed)', style: TextStyle(fontSize: 12)),
                  Text(
                    '\$${totalRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}