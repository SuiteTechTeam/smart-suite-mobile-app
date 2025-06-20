// TODO: Refactor in widgets
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/reservation.dart';
import '../models/reservation_resource.dart';
import '../services/reservation_service.dart';
import '../widgets/section_title.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/resource_type_dropdown.dart';
import '../widgets/date_time_selection.dart';
import '../widgets/resource_selection.dart';

class AddReservationScreen extends StatefulWidget {
  final int? hotelId;
  const AddReservationScreen({super.key, this.hotelId});

  @override
  State<AddReservationScreen> createState() => _AddReservationScreenState();
}

class _AddReservationScreenState extends State<AddReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late ReservationService _reservationService;
  final storage = const FlutterSecureStorage();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _guestCountController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  // Form state
  String selectedResourceType = 'restaurant';
  int? selectedResourceId;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? hotelId;
  List<ReservationResource> availableResources = [];
  bool isLoadingResources = false;
  String? _userRole; // Rol del usuario autenticado

  final List<String> resourceTypes = [
    'restaurant',
    'spa',
    'conference_room',
    'gym',
    'pool',
    'equipment',
  ];
  @override
  void initState() {
    super.initState();
    _reservationService = ReservationService();
    _initHotelId();
    _loadUserInfo();
    _guestCountController.text = '1';
  }

  Future<void> _initHotelId() async {
    // 1. Try to get hotelId from widget (navigation argument)
    if (widget.hotelId != null) {
      setState(() {
        hotelId = widget.hotelId;
      });
      return;
    }
    // 2. Try to get hotelId from ModalRoute arguments (if pushed via Navigator)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['hotelId'] is int) {
      setState(() {
        hotelId = args['hotelId'] as int;
      });
      return;
    }
    // 3. Fallback to previous logic (token or secure storage)
    await _loadHotelId();
  }

  Future<void> _loadUserInfo() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        // Usar claims estándar
        String? userId = decodedToken['sid']?.toString();
        if (userId != null && _customerIdController.text.isEmpty) {
          _customerIdController.text = userId;
        }
        // Set default title based on user email if available
        String? userEmail = decodedToken['email'];
        if (userEmail != null && _titleController.text.isEmpty) {
          _titleController.text = 'Reservation for $userEmail';
        }
        // Guardar el rol para uso posterior si es necesario
        setState(() {
          _userRole = decodedToken['role']?.toString().toLowerCase();
        });
      } catch (e) {
        // Token parsing failed, continue without pre-filling
      }
    }
  }

  Future<int?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? locality = decodedToken['locality'];
      return locality != null ? int.tryParse(locality) : null;
    }
    return null;
  }

  Future<void> _loadHotelId() async {
    // First try to get hotel ID from JWT token
    int? tokenHotelId = await _getHotelId();
    if (tokenHotelId != null) {
      setState(() {
        hotelId = tokenHotelId;
      });
      return;
    }

    // If not in token, try to get from stored preferences
    int? storedHotelId = await _getStoredHotelId();
    if (storedHotelId != null) {
      setState(() {
        hotelId = storedHotelId;
      });
      return;
    }

    // If no hotel ID found anywhere, show dialog
    _showHotelIdDialog();
  }

  Future<int?> _getStoredHotelId() async {
    String? storedHotelId = await storage.read(key: 'selected_hotel_id');
    return storedHotelId != null ? int.tryParse(storedHotelId) : null;
  }

  void _showHotelIdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hotel ID Required'),
          content: const Text(
            'No hotel ID was found. Please enter a hotel ID to continue.',
          ),
          actions: [
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
    setState(() {
      hotelId = newHotelId;
    });

    // Store the hotel ID in secure storage for future use
    await storage.write(key: 'selected_hotel_id', value: newHotelId.toString());

    _showSnackBar('Hotel ID set to $newHotelId');
  }

  Future<void> _loadAvailableResources() async {
    if (hotelId == null ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      return;
    }

    setState(() {
      isLoadingResources = true;
    });

    try {
      // Since getAvailableResources doesn't exist in the API, we'll create mock resources
      // In a real implementation, you would call an API to get available rooms
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      setState(() {
        availableResources = [
          ReservationResource(
            id: 1,
            name: 'Standard Room',
            type: 'room',
            description: 'Standard hotel room',
            capacity: 2,
            pricePerHour: 50.0,
            status: 'available',
            hotelId: hotelId!,
          ),
          ReservationResource(
            id: 2,
            name: 'Deluxe Room',
            type: 'room',
            description: 'Deluxe hotel room',
            capacity: 3,
            pricePerHour: 80.0,
            status: 'available',
            hotelId: hotelId!,
          ),
          ReservationResource(
            id: 3,
            name: 'Suite',
            type: 'room',
            description: 'Luxury suite',
            capacity: 4,
            pricePerHour: 120.0,
            status: 'available',
            hotelId: hotelId!,
          ),
        ];
        selectedResourceId = null; // Reset selection
        isLoadingResources = false;
      });
    } catch (e) {
      setState(() {
        isLoadingResources = false;
      });
      _showSnackBar('Failed to load available resources: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _loadAvailableResources();
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
      _loadAvailableResources();
    }
  }

  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null ||
        startTime == null ||
        endTime == null ||
        selectedResourceId == null) {
      _showSnackBar('Please complete all required fields');
      return;
    }

    try {
      final startDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        startTime!.hour,
        startTime!.minute,
      );

      final endDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        endTime!.hour,
        endTime!.minute,
      );

      // Calculate total amount (simplified calculation)
      final duration = endDateTime.difference(startDateTime).inHours;
      final selectedResource = availableResources.firstWhere(
        (r) => r.id == selectedResourceId,
      );
      final totalAmount = duration * selectedResource.pricePerHour;
      final reservation = Reservation(
        paymentCustomerId: int.parse(_customerIdController.text),
        roomId: selectedResourceId!,
        description: _descriptionController.text,
        startDate: selectedDate!,
        finalDate: endDateTime,
        priceRoom:
            selectedResource.pricePerHour, // Using this as room price for now
        nightCount: duration > 0 ? duration : 1,
        amount: totalAmount,
        state: 'pending',
        preferenceId: 0, // Default preference ID
      );

      await _reservationService.createReservation(reservation);

      if (mounted) {
        _showSnackBar('Reservation created successfully');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create reservation: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Reservation'),
        backgroundColor: const Color(0xFF474C74),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Basic Information'),
              CustomTextField(
                controller: _titleController,
                label: 'Reservation Title',
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a title' : null,
              ),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              CustomTextField(
                controller: _customerIdController,
                label: 'Customer ID',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter customer ID' : null,
                enabled: _userRole != 'guest',
              ),
              const SizedBox(height: 24),
              SectionTitle('Resource & Time'),
              ResourceTypeDropdown(
                selectedResourceType: selectedResourceType,
                resourceTypes: resourceTypes,
                onChanged: (value) {
                  setState(() {
                    selectedResourceType = value!;
                    availableResources.clear();
                    selectedResourceId = null;
                  });
                  _loadAvailableResources();
                },
              ),
              DateTimeSelection(
                selectedDate: selectedDate,
                startTime: startTime,
                endTime: endTime,
                onSelectDate: _selectDate,
                onSelectStartTime: () => _selectTime(true),
                onSelectEndTime: () => _selectTime(false),
              ),
              ResourceSelection(
                isLoadingResources: isLoadingResources,
                availableResources: availableResources,
                selectedResourceId: selectedResourceId,
                onChanged: (value) {
                  setState(() {
                    selectedResourceId = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SectionTitle('Additional Details'),
              CustomTextField(
                controller: _guestCountController,
                label: 'Number of Guests',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter guest count' : null,
              ),
              CustomTextField(
                controller: _specialRequestsController,
                label: 'Special Requests (Optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF474C74),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Reservation',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _customerIdController.dispose();
    _guestCountController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }
}
