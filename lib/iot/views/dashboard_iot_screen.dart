import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/room_summary.dart';
import '../models/temperature/temperature_data.dart';
import '../services/iot_service.dart';
import '../widgets/room_overview_card.dart';
import '../widgets/room_status_card.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/device_status_card.dart';
import 'iot_device_list_screen.dart';
import 'iot_device_detail_screen.dart';
import '../../hotels/models/room.dart';
import '../../hotels/services/room_service.dart';

class DashboardIotScreen extends StatefulWidget {
  const DashboardIotScreen({super.key});

  @override
  State<DashboardIotScreen> createState() => _DashboardIotScreenState();
}

class _DashboardIotScreenState extends State<DashboardIotScreen> {
  final IotService _iotService = IotService();
  final RoomService _roomService = RoomService();
  
  int _selectedRoomId = 101;
  String _selectedRoomName = 'Habitación 101';
  int _selectedFloor = 1;
  
  List<RoomSummary> _rooms = [];
  bool _isLoading = true;
    @override
  void initState() {
    super.initState();
    _loadRooms();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Attempt to load real rooms from API
      final rooms = await _roomService.getRoomsByHotelId(1);
      
      if (rooms.isNotEmpty) {
        _rooms = rooms.map((room) => RoomSummary.fromRoom(room)).toList();
        
        // Set the first room as selected
        if (_rooms.isNotEmpty) {
          _selectedRoomId = _rooms[0].id;
          _selectedRoomName = _rooms[0].name;
          _selectedFloor = _rooms[0].floor;
        }
      } else {
        // Create mock rooms for demonstration
        _rooms = _createMockRooms();
      }
    } catch (e) {
      // Create mock rooms for demonstration in case of an error
      _rooms = _createMockRooms();
      debugPrint('Error loading rooms: $e');
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.hotel, color: Colors.lightBlue),
            const SizedBox(width: 8),
            Text('Hotel Smart Control', 
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                )),
          ],
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.indigo,
            ),            onPressed: () {
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
      ),      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardTab(),
    );
  }
    // Dashboard tab is now the only view
    Widget _buildDashboardTab() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Filter rooms by the selected floor for the room list
    final roomsOnSelectedFloor = _rooms.where((r) => r.floor == _selectedFloor).toList();
    
    // Find the selected room
    final selectedRoom = _rooms.firstWhere(
      (room) => room.id == _selectedRoomId,
      orElse: () => _rooms.first,
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.1),
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
                        ),                        Text(
                          'Piso $_selectedFloor',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[600]),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: selectedRoom.status.color.withOpacity(0.2),
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
      ),
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
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
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
              const Text(
                'Hotel Smart Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),              Text(
                'Sistema de gestión IoT',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[300] 
                      : Colors.grey[600],
                  fontSize: 14
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
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
              Tab(icon: Icon(Icons.thermostat_outlined), text: 'Temperatura'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'Configuración'),
            ],
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                // Devices Tab
                _buildDevicesTab(selectedRoom),
                
                // Temperature Tab
                _buildTemperatureTab(selectedRoom),
                
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dispositivos conectados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Administrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          // Mock device grid for demonstration
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
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
        ],
      ),
    );
  }

  Widget _buildTemperatureTab(RoomSummary room) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: FutureBuilder<List<TemperatureData>>(
        future: _iotService.getRoomTemperatureHistory(room.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final data = snapshot.data ?? [];
          return TemperatureChart(
            temperatureData: data,
            title: 'Histórico de Temperatura (24h)',
            subtitle: 'Temperatura registrada en °C para ${room.name}',
          );
        },
      ),
    );
  }
    Widget _buildConfigurationTab(RoomSummary room) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [                ListTile(
                  leading: const Icon(Icons.thermostat_outlined),
                  title: const Text('Temperatura predeterminada'),
                  subtitle: const Text('23°C'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconColor: isDarkMode ? Colors.white70 : null,
                  textColor: isDarkMode ? Colors.white : null,
                ),
                Divider(height: 1, color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Horario de limpieza'),
                  subtitle: const Text('9:00 AM - 11:00 AM'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  iconColor: isDarkMode ? Colors.white70 : null,
                  textColor: isDarkMode ? Colors.white : null,
                ),
                Divider(height: 1, color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
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
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Floor selector
          Row(
            children: [
              const Text('Piso:', style: TextStyle(fontWeight: FontWeight.w500)),
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
                },                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      if (states.contains(MaterialState.selected)) {
                        return isDarkMode ? Colors.blue.shade700 : Colors.lightBlue;
                      }
                      return isDarkMode ? Colors.grey.shade800 : Colors.white;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      return isDarkMode ? Colors.white70 : Colors.black87;
                    },
                  ),
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
              childAspectRatio: 3/2,
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