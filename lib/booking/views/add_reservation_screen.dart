import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import '../models/available_room.dart';
import '../services/booking_flow_service.dart';
import '../widgets/section_title.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/available_room_selection.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/guest_selection.dart';
import '../../iam/services/guest_service.dart';

class AddReservationScreen extends StatefulWidget {
  final int? hotelId;
  const AddReservationScreen({super.key, this.hotelId});

  @override
  State<AddReservationScreen> createState() => _AddReservationScreenState();
}

class _AddReservationScreenState extends State<AddReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late BookingFlowService _bookingFlowService;
  final storage = const FlutterSecureStorage();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guestCountController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  // Guest selection
  Guest? _selectedGuest;

  // Form state
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int? hotelId;
  List<AvailableRoom> availableRooms = [];
  AvailableRoom? selectedRoom;
  bool isLoadingRooms = false;
  bool _isCreatingReservation = false;

  @override
  void initState() {
    super.initState();
    _bookingFlowService = BookingFlowService();
    _loadUserInfo();
    _guestCountController.text = '1';
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initHotelId();
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
    // Set default title
    if (_titleController.text.isEmpty) {
      _titleController.text = 'Nueva Reservación';
    }
  }

  Future<int?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String? locality = decodedToken['locality'];
        return locality != null ? int.tryParse(locality) : null;
      } catch (e) {
        return null;
      }
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
          title: const Text('Hotel ID Requerido'),
          content: const Text(
            'No se encontró un hotel ID. Por favor ingrese un hotel ID para continuar.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showHotelIdInputDialog();
              },
              child: const Text('Ingresar Hotel ID'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _useDefaultHotelId();
              },
              child: const Text('Usar Default (1)'),
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
          title: const Text('Ingresar Hotel ID'),
          content: TextField(
            controller: hotelIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Hotel ID',
              hintText: 'Ingrese su hotel ID (ej: 1)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
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
                    _showSnackBar('Por favor ingrese un hotel ID válido');
                  }
                } else {
                  _showSnackBar('Por favor ingrese un hotel ID');
                }
              },
              child: const Text('Confirmar'),
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

    _showSnackBar('Hotel ID establecido en $newHotelId');
  }

  void _onGuestSelected(Guest guest) {
    setState(() {
      _selectedGuest = guest;
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
        // Reset end date if it's before start date
        if (selectedEndDate != null && selectedEndDate!.isBefore(picked)) {
          selectedEndDate = null;
        }
      });
      _loadAvailableRooms();
    }
  }

  Future<void> _selectEndDate() async {
    if (selectedStartDate == null) {
      _showSnackBar('Por favor seleccione primero la fecha de llegada');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate!.add(const Duration(days: 1)),
      firstDate: selectedStartDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
      });
      _loadAvailableRooms();
    }
  }

  Future<void> _loadAvailableRooms() async {
    if (hotelId == null || selectedStartDate == null || selectedEndDate == null) {
      return;
    }

    setState(() {
      isLoadingRooms = true;
      selectedRoom = null;
    });

    try {
      List<AvailableRoom> rooms = await _bookingFlowService.getAvailableRooms(
        hotelId: hotelId!,
        startDate: selectedStartDate!,
        finalDate: selectedEndDate!,
      );

      setState(() {
        availableRooms = rooms;
        isLoadingRooms = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRooms = false;
      });
      _showSnackBar('Error al cargar habitaciones disponibles: $e');
    }
  }

  void _onRoomSelected(AvailableRoom room) {
    setState(() {
      selectedRoom = room;
    });
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado un huésped
    if (_selectedGuest == null || _selectedGuest!.id == 0) {
      _showSnackBar('Por favor seleccione un huésped');
      return;
    }

    // Validar que se haya seleccionado una habitación
    if (selectedRoom == null) {
      _showSnackBar('Por favor seleccione una habitación');
      return;
    }

    // Validar fechas
    if (selectedStartDate == null || selectedEndDate == null) {
      _showSnackBar('Por favor seleccione las fechas de llegada y salida');
      return;
    }

    // Validar hotel ID
    if (hotelId == null) {
      _showSnackBar('Error: No se encontró el hotel ID');
      return;
    }

    setState(() {
      _isCreatingReservation = true;
    });

    try {
      print('Debug - Creando reservación con datos:');
      print('  hotelId: $hotelId');
      print('  roomId: ${selectedRoom!.room.id}');
      print('  guestId: ${_selectedGuest!.id}');
      print('  startDate: $selectedStartDate');
      print('  endDate: $selectedEndDate');
      print('  title: ${_titleController.text}');
      print('  description: ${_descriptionController.text}');
      print('  guestCount: ${_guestCountController.text}');
      print('  specialRequests: ${_specialRequestsController.text}');

      // Crear la reservación usando el BookingFlowService
      final reservation = await _bookingFlowService.createBooking(
        guestId: _selectedGuest!.id,
        roomId: selectedRoom!.room.id,
        description: _descriptionController.text,
        startDate: selectedStartDate!,
        finalDate: selectedEndDate!,
        pricePerNight: selectedRoom!.pricePerNight,
      );

      setState(() {
        _isCreatingReservation = false;
      });

      _showSnackBar('Reservación creada exitosamente');
      
      // Navegar de vuelta o mostrar detalles
      if (mounted) {
        Navigator.of(context).pop(reservation);
      }
    } catch (e) {
      setState(() {
        _isCreatingReservation = false;
      });
      _showSnackBar('Error al crear la reservación: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reservación'),
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
              // Guest Selection Section
              GuestSelection(
                onGuestSelected: _onGuestSelected,
                selectedGuestId: _selectedGuest?.id,
                hotelId: hotelId,
              ),
              
              const SizedBox(height: 24),
              
              // Basic Information Section
              SectionTitle('Información Básica'),
              CustomTextField(
                controller: _titleController,
                label: 'Título de la Reservación',
                validator: (value) =>
                    value?.isEmpty == true ? 'Por favor ingrese un título' : null,
              ),
              CustomTextField(
                controller: _descriptionController,
                label: 'Descripción',
                maxLines: 3,
              ),
              CustomTextField(
                controller: _guestCountController,
                label: 'Número de Huéspedes',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Por favor ingrese el número de huéspedes' : null,
              ),
              CustomTextField(
                controller: _specialRequestsController,
                label: 'Solicitudes Especiales (Opcional)',
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Date Selection Section
              SectionTitle('Fechas de Estancia'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleccione las fechas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Start Date
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFF474C74)),
                        title: const Text('Fecha de Llegada'),
                        subtitle: Text(
                          selectedStartDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedStartDate!)
                              : 'Seleccionar fecha',
                        ),
                        onTap: _selectStartDate,
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                      
                      // End Date
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFF474C74)),
                        title: const Text('Fecha de Salida'),
                        subtitle: Text(
                          selectedEndDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedEndDate!)
                              : 'Seleccionar fecha',
                        ),
                        onTap: _selectEndDate,
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Available Rooms Section
              if (selectedStartDate != null && selectedEndDate != null)
                AvailableRoomSelection(
                  availableRooms: availableRooms,
                  selectedRoomId: selectedRoom?.room.id,
                  onRoomSelected: (roomId) {
                    if (roomId != null) {
                      AvailableRoom? room = availableRooms.firstWhere(
                        (r) => r.room.id == roomId,
                        orElse: () => availableRooms.first,
                      );
                      _onRoomSelected(room);
                    } else {
                      setState(() {
                        selectedRoom = null;
                      });
                    }
                  },
                  isLoading: isLoadingRooms,
                ),
              
              const SizedBox(height: 24),
              
              // Booking Summary Section
              if (selectedRoom != null && selectedStartDate != null && selectedEndDate != null)
                BookingSummaryCard(
                  selectedRoom: selectedRoom!,
                  startDate: selectedStartDate!,
                  finalDate: selectedEndDate!,
                  description: _descriptionController.text,
                  guestCount: int.tryParse(_guestCountController.text) ?? 1,
                  specialRequests: _specialRequestsController.text.isNotEmpty 
                      ? _specialRequestsController.text 
                      : null,
                ),
              
              const SizedBox(height: 32),
              
              // Create Reservation Button
              if (_selectedGuest != null && _selectedGuest!.id > 0 && 
                  selectedRoom != null && selectedStartDate != null && selectedEndDate != null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCreatingReservation ? null : _createReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF474C74),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isCreatingReservation
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Creando...',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          )
                        : const Text(
                            'Crear Reservación',
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
    _guestCountController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }
}


