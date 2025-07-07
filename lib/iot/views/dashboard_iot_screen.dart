import 'package:flutter/material.dart';

import '../models/room_summary.dart';
import '../models/temperature/temperature_data.dart';
import '../models/notification_history/notification_history.dart';
import '../services/iot_service.dart';
import '../widgets/room_overview_card.dart';
import '../widgets/room_status_card.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/device_status_card.dart';
import '../widgets/notification_history_list_tile.dart';
import '../widgets/latest_metrics_summary.dart';
import 'iot_device_list_screen.dart';
import '../../hotels/models/hotel.dart';
import '../../hotels/services/room_service.dart';
import '../../hotels/services/hotel_service.dart';

class DashboardIotScreen extends StatefulWidget {
  const DashboardIotScreen({super.key});

  @override
  State<DashboardIotScreen> createState() => _DashboardIotScreenState();
}

class _DashboardIotScreenState extends State<DashboardIotScreen> {
  final IotService _iotService = IotService();
  final RoomService _roomService = RoomService();
  final HotelService _hotelService = HotelService();

  int _selectedRoomId = 101;
  String _selectedRoomName = 'Habitación 101';
  int _selectedFloor = 1;

  List<RoomSummary> _rooms = [];
  List<Hotel> _hotels = [];
  int _selectedHotelId = 1;
  String _selectedHotelName = 'Cargando...';
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to load hotels from API
      final hotels = await _hotelService.getAllHotels();

      if (hotels.isNotEmpty) {
        _hotels = hotels;
        _selectedHotelId = hotels[0].id;
        _selectedHotelName = hotels[0].name;

        // After loading hotels, load rooms for the selected hotel
        await _loadRooms(_selectedHotelId);
      } else {
        // Create mock hotels and rooms if no real data available
        _createMockHotels();
        _rooms = _createMockRooms();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading hotels: $e');
      // Create mock hotels and rooms for demonstration in case of an error
      _createMockHotels();
      _rooms = _createMockRooms();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMockHotels() {
    _hotels = [
      Hotel(
        id: 1,
        name: 'Hotel Smart Control',
        address: 'Calle Principal 123',
        phone: '123-456-7890',
        email: 'contact@smartcontrol.com',
        createdAt: DateTime.now(),
      ),
      Hotel(
        id: 2,
        name: 'Grand Hotel Plaza',
        address: 'Avenida Central 456',
        phone: '987-654-3210',
        email: 'info@grandhotel.com',
        createdAt: DateTime.now(),
      ),
      Hotel(
        id: 3,
        name: 'Ocean View Resort',
        address: 'Playa del Mar 789',
        phone: '555-123-4567',
        email: 'reservations@oceanview.com',
        createdAt: DateTime.now(),
      ),
    ];
    _selectedHotelId = 1;
    _selectedHotelName = 'Hotel Smart Control';
  }

  Future<void> _loadRooms(int hotelId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to load real rooms from API
      final rooms = await _roomService.getRoomsByHotelId(hotelId);

      if (rooms.isNotEmpty) {
        _rooms = rooms.map((room) => RoomSummary.fromRoom(room)).toList();

        // Load IoT metrics for each room to get real temperature data
        await _loadRoomTemperatures();

        // Set the first room as selected
        if (_rooms.isNotEmpty) {
          _selectedRoomId = _rooms[0].id;
          _selectedRoomName = _rooms[0].name;
          _selectedFloor = _rooms[0].floor;
        }
      } else {
        // Create mock rooms for demonstration
        _rooms = _createMockRooms();
        await _loadRoomTemperatures();
      }
    } catch (e) {
      // Create mock rooms for demonstration in case of an error
      _rooms = _createMockRooms();
      await _loadRoomTemperatures();
      debugPrint('Error loading rooms: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoomTemperatures() async {
    // Load temperature data for each room from IoT metrics
    for (int i = 0; i < _rooms.length; i++) {
      try {
        final notifications = await _iotService.getNotificationhistoryByRoom(_rooms[i].id);
        if (notifications.isNotEmpty) {
          // Get the most recent notification
          final latestNotification = notifications.first;
          final temperature = _extractTemperatureFromMetrics(latestNotification.metric);
          if (temperature != null) {
            // Create a new RoomSummary with the real temperature
            _rooms[i] = RoomSummary(
              id: _rooms[i].id,
              number: _rooms[i].number,
              name: _rooms[i].name,
              floor: _rooms[i].floor,
              status: _rooms[i].status,
              currentTemperature: temperature,
            );
          }
        }
      } catch (e) {
        debugPrint('Error loading temperature for room ${_rooms[i].id}: $e');
      }
    }
  }

  double? _extractTemperatureFromMetrics(String metricString) {
    final parts = metricString.split(';');
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2 && keyValue[0] == 'temp') {
        return double.tryParse(keyValue[1]);
      }
    }
    return null;
  }

  List<RoomSummary> _createMockRooms() {
    return [
      RoomSummary(
        id: 101,
        name: 'Habitación 101',
        floor: 1,
        status: RoomOccupancyStatus.ocupada,
        number: 101,
        currentTemperature: 23.5,
      ),
      RoomSummary(
        id: 102,
        name: 'Habitación 102',
        floor: 1,
        status: RoomOccupancyStatus.libre,
        number: 102,
        currentTemperature: 22.0,
      ),
      RoomSummary(
        id: 103,
        name: 'Habitación 103',
        floor: 1,
        status: RoomOccupancyStatus.mantenimiento,
        number: 103,
        currentTemperature: 24.2,
      ),
      RoomSummary(
        id: 201,
        name: 'Habitación 201',
        floor: 2,
        status: RoomOccupancyStatus.ocupada,
        number: 201,
        currentTemperature: 24.8,
      ),
      RoomSummary(
        id: 202,
        name: 'Habitación 202',
        floor: 2,
        status: RoomOccupancyStatus.libre,
        number: 202,
        currentTemperature: 21.5,
      ),
      RoomSummary(
        id: 203,
        name: 'Habitación 203',
        floor: 2,
        status: RoomOccupancyStatus.ocupada,
        number: 203,
        currentTemperature: 23.1,
      ),
    ];
  }

  void _onRoomSelected(RoomSummary room) {
    setState(() {
      _selectedRoomId = room.id;
      _selectedRoomName = room.name;
      _selectedFloor = room.floor;
    });
  }

  void _onHotelSelected(Hotel hotel) {
    setState(() {
      _selectedHotelId = hotel.id;
      _selectedHotelName = hotel.name;
      _isLoading = true;
    });

    // Load rooms for the selected hotel
    _loadRooms(hotel.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.hotel, color: Colors.lightBlue),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedHotelId,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      final selectedHotel = _hotels.firstWhere(
                        (hotel) => hotel.id == newValue,
                      );
                      _onHotelSelected(selectedHotel);
                    }
                  },
                  items: _hotels.map<DropdownMenuItem<int>>((Hotel hotel) {
                    return DropdownMenuItem<int>(
                      value: hotel.id,
                      child: Text(hotel.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Refresh IoT data button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _loadRoomTemperatures();
              setState(() {
                _isLoading = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos IoT actualizados'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Actualizar datos IoT',
          ),
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.indigo,
            ),
            onPressed: () {
              // This is just a placeholder - in a real app, you would
              // use a state management solution to toggle the theme
              // For demonstration purposes, we'll show a snackbar here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isDarkMode
                        ? 'Changing to light mode (requires theme implementation)'
                        : 'Changing to dark mode (requires theme implementation)',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
              // NOTE: The actual theme toggle would be implemented in the app's
              // root widget with a proper theme state management
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardTab(),
    );
  }

  // Dashboard tab is now the only view
  Widget _buildDashboardTab() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Filter rooms by the selected floor for the room list
    final roomsOnSelectedFloor = _rooms
        .where((r) => r.floor == _selectedFloor)
        .toList();

    // Find the selected room
    final selectedRoom = _rooms.firstWhere(
      (room) => room.id == _selectedRoomId,
      orElse: () => _rooms.first,
    );
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Hotel title section
        _buildHotelHeader(),

        const SizedBox(height: 16),

        // Room overview statistics
        RoomOverviewCard.fromRooms(_rooms),

        const SizedBox(height: 16),
        // Selected Room Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues( alpha: 0.2)
                    : Colors.grey.withValues( alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRoomName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Piso $_selectedFloor',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: selectedRoom.status.color.withValues( alpha: 0.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedRoom.status == RoomOccupancyStatus.ocupada
                              ? Icons.person
                              : selectedRoom.status == RoomOccupancyStatus.libre
                              ? Icons.check_circle
                              : Icons.handyman,
                          size: 16,
                          color: selectedRoom.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedRoom.status.label,
                          style: TextStyle(
                            color: selectedRoom.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Room Controls Tabs
              _buildRoomDetailTabs(selectedRoom),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // Room list section
        _buildRoomListSection(roomsOnSelectedFloor),
      ],
    );
  }

  Widget _buildHotelHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues( alpha: 0.2)
                : Colors.grey.withValues( alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.hotel, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedHotelName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sistema de gestión IoT',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailTabs(RoomSummary selectedRoom) {
    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
              Tab(icon: Icon(Icons.thermostat_outlined), text: 'Temperatura'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'Configuración'),
            ],
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 350, // Increased height to prevent overflow
            child: TabBarView(
              children: [
                // Devices Tab
                _buildDevicesTab(selectedRoom),

                // Temperature Tab
                _buildTemperatureTab(selectedRoom),

                // History Tab
                _buildHistoryTab(selectedRoom),

                // Configuration Tab
                _buildConfigurationTab(selectedRoom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab(RoomSummary room) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dispositivos conectados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Administrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IotDeviceListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Latest metrics summary
        FutureBuilder<List<NotificationHistory>>(
          future: _iotService.getNotificationhistoryByRoom(room.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            final notifications = snapshot.data ?? [];
            return LatestMetricsSummary(
              notifications: notifications,
              roomName: room.name,
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Mock device grid for demonstration
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DeviceStatusCard(
                deviceName: 'Sensor de temperatura',
                isConnected: true,
                deviceType: DeviceType.temperature,
              ),
              DeviceStatusCard(
                deviceName: 'Sensor de humedad',
                isConnected: true,
                deviceType: DeviceType.humidity,
              ),
              DeviceStatusCard(
                deviceName: 'Control de AC',
                isConnected: false,
                deviceType: DeviceType.ac,
              ),
              DeviceStatusCard(
                deviceName: 'Iluminación',
                isConnected: true,
                deviceType: DeviceType.lighting,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureTab(RoomSummary room) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 300,
        child: FutureBuilder<List<NotificationHistory>>(
          future: _iotService.getNotificationhistoryByRoom(room.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error al cargar datos de temperatura',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }

            final notifications = snapshot.data ?? [];
            
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay datos de temperatura',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Los datos aparecerán cuando los dispositivos IoT envíen información',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Convert notifications to TemperatureData
            final temperatureData = _convertNotificationsToTemperatureData(notifications, room.name);
            
            return TemperatureChart(
              temperatureData: temperatureData,
              title: 'Histórico de Temperatura IoT',
              subtitle: 'Temperatura registrada por dispositivos IoT en ${room.name}',
            );
          },
        ),
      ),
    );
  }

  List<TemperatureData> _convertNotificationsToTemperatureData(List<NotificationHistory> notifications, String roomName) {
    final List<TemperatureData> temperatureData = [];
    
    for (final notification in notifications) {
      final temperature = _extractTemperatureFromMetrics(notification.metric);
      if (temperature != null) {
        temperatureData.add(TemperatureData(
          roomId: notification.roomDeviceId,
          value: temperature,
          timestamp: notification.registrationDate,
        ));
      }
    }
    
    // Sort by timestamp (most recent first)
    temperatureData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Limit to last 24 entries for better visualization
    if (temperatureData.length > 24) {
      return temperatureData.take(24).toList();
    }
    
    return temperatureData;
  }

  Widget _buildHistoryTab(RoomSummary room) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial de Notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  // Trigger rebuild to refresh data
                });
              },
              tooltip: 'Actualizar',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        FutureBuilder<List<NotificationHistory>>(
          future: _iotService.getNotificationhistoryByRoom(room.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar el historial',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final notifications = snapshot.data ?? [];
            
            if (notifications.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay notificaciones',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Los datos aparecerán cuando los dispositivos IoT envíen información',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: notifications.map((notification) {
                return NotificationHistoryListTile(
                  notification: notification,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfigurationTab(RoomSummary room) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajustes de la habitación',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.thermostat_outlined),
                  title: const Text('Temperatura predeterminada'),
                  subtitle: const Text('23°C'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconColor: isDarkMode ? Colors.white70 : null,
                  textColor: isDarkMode ? Colors.white : null,
                ),
                Divider(
                  height: 1,
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Horario de limpieza'),
                  subtitle: const Text('9:00 AM - 11:00 AM'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconColor: isDarkMode ? Colors.white70 : null,
                  textColor: isDarkMode ? Colors.white : null,
                ),
                Divider(
                  height: 1,
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Alertas y notificaciones'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconColor: isDarkMode ? Colors.white70 : null,
                  textColor: isDarkMode ? Colors.white : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomListSection(List<RoomSummary> roomsOnSelectedFloor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues( alpha: 0.2)
                : Colors.grey.withValues( alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habitaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Floor selector
          Row(
            children: [
              const Text(
                'Piso:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 1, label: const Text('1')),
                  ButtonSegment(value: 2, label: const Text('2')),
                ],
                selected: {_selectedFloor},
                onSelectionChanged: (Set<int> selection) {
                  setState(() {
                    _selectedFloor = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    if (states.contains(WidgetState.selected)) {
                      return isDarkMode
                          ? Colors.blue.shade700
                          : Colors.lightBlue;
                    }
                    return isDarkMode ? Colors.grey.shade800 : Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return isDarkMode ? Colors.white70 : Colors.black87;
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Room grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemCount: roomsOnSelectedFloor.length,
            itemBuilder: (context, index) {
              final room = roomsOnSelectedFloor[index];
              return RoomStatusCard(
                room: room,
                onTap: () => _onRoomSelected(room),
                isSelected: room.id == _selectedRoomId,
              );
            },
          ),
        ],
      ),
    );
  }
}
