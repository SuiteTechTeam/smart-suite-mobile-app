// messageScreen.dart
import 'package:flutter/material.dart';
import 'package:sweetmanager/Communication/services/NotificationService.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';
import '../models/notification.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'writeMessage.dart'; // Import WriteMessage

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Notifications> _messages = []; // Lista de mensajes
  
  List<Notifications> _filteredMessages = [];
  
  // ignore: unused_field
  String _searchQuery = '';
  
  final Set<int> _selectedMessageIndices = {};

  bool isLoading = true;

  late NotificationService notificationService;

  final storage = const FlutterSecureStorage();

  int? hotelId; // Define hotelId

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();

    _loadHotelId();
  }

  // Cargar hotel ID desde el almacenamiento seguro
  Future<void> _loadHotelId() async {
    String? token = await storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        hotelId = int.tryParse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString() ?? '');
      });
      fetchMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotel ID no encontrado o token expirado')));
    }
  }

  // Obtener mensajes del backend
  Future<void> fetchMessages() async {
    if (hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotel ID no encontrado')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final messages = await notificationService.getMessages(hotelId!);
      setState(() {
        _messages = messages;
        _filteredMessages = messages; // Inicializa los mensajes filtrados con todos los mensajes
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar mensajes: $e')));
    }
  }

  // Filtrar mensajes por consulta de búsqueda
  void _filterMessages(String query) {
    setState(() {
      _searchQuery = query; // Actualiza la consulta de búsqueda
      _filteredMessages = _messages.where((notification) {
        return notification.title!.toLowerCase().contains(query.toLowerCase().trim());
      }).toList();
    });
  }

  // Eliminar mensajes seleccionados
  void _deleteSelectedMessages() {
    setState(() {
      _filteredMessages.removeWhere((notification) =>
          _selectedMessageIndices.contains(_filteredMessages.indexOf(notification)));
      _selectedMessageIndices.clear();
    });
  }

  // Seleccionar o deseleccionar un mensaje
  void _selectMessage(int index) {
    setState(() {
      if (_selectedMessageIndices.contains(index)) {
        _selectedMessageIndices.remove(index);
      } else {
        _selectedMessageIndices.add(index);
      }
    });
  }

  Future<String?> _getRole() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getRole(),
      builder: (context, snapshot) {
        
        if(snapshot.hasData)
        {
          String? role = snapshot.data;

          return BaseLayout(
            role: role,
            childScreen: getContentView(role!)
          );
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }


  Widget getContentView(String role) {
    if(role == 'ROLE_WORKER')
    {
      _filteredMessages = _filteredMessages.where((n)=> n.ownersId != 0 && n.workersId == null && n.adminsId != 0).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: _filterMessages,
                decoration: InputDecoration(
                  hintText: 'Search message',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF4A4E69),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: _filteredMessages.length,
                  itemBuilder: (context, index) {
                    final notification = _filteredMessages[index];
                    return Dismissible(
                      key: Key(notification.title!),
                      onDismissed: (direction) {
                        setState(() {
                          _filteredMessages.removeAt(index);
                          _selectedMessageIndices.remove(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mensaje eliminado')),
                        );
                      },
                      background: Container(color: Colors.red),
                      child: MessageTile(
                        title: notification.title!,
                        recipient: notification.description!,
                        date: notification.typesNotificationsId.toString(),
                        isSelected: _selectedMessageIndices.contains(index),
                        onSelect: () => _selectMessage(index),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _selectedMessageIndices.isNotEmpty
                        ? _deleteSelectedMessages
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Delete selected',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
         ],
      ),
    );
    }
    else
    {
      _filteredMessages= _filteredMessages.where((n)=> n.ownersId != 0 && n.workersId == null && n.adminsId == null).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: _filterMessages,
                decoration: InputDecoration(
                  hintText: 'Search message',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF4A4E69),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: _filteredMessages.length,
                  itemBuilder: (context, index) {
                    final notification = _filteredMessages[index];
                    return Dismissible(
                      key: Key(notification.title!),
                      onDismissed: (direction) {
                        setState(() {
                          _filteredMessages.removeAt(index);
                          _selectedMessageIndices.remove(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mensaje eliminado')),
                        );
                      },
                      background: Container(color: Colors.red),
                      child: MessageTile(
                        title: notification.title!,
                        recipient: notification.description!,
                        date: notification.typesNotificationsId.toString(),
                        isSelected: _selectedMessageIndices.contains(index),
                        onSelect: () => _selectMessage(index),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteMessage()),
                      );
                      if (result == true) {
                        fetchMessages(); // Reload messages if a new message was created
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
                      'Create message',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedMessageIndices.isNotEmpty
                        ? _deleteSelectedMessages
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Delete selected',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
      );
    }
  }

}

// Suponiendo que este es el widget MessageTile utilizado en el constructor
class MessageTile extends StatelessWidget {
  final String title;
  final String recipient;
  final String date;
  final bool isSelected;
  final VoidCallback onSelect;

  const MessageTile({super.key, 
    required this.title,
    required this.recipient,
    required this.date,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text('$recipient, $date'),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => onSelect(),
      ),
    );
  }
}