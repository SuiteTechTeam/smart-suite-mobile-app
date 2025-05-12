import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Commerce/services/commerce_service.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/services/roomservice.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class RoomTypesSetup extends StatefulWidget {

  const RoomTypesSetup({super.key});

  @override
  State<RoomTypesSetup> createState() => _RoomTypesSetupState();
}

class _RoomTypesSetupState extends State<RoomTypesSetup> {

  final _commerceService = CommerceService();

  final _monitoringService = RoomService();

  final storage = const FlutterSecureStorage();

  final List<Map<String, dynamic>> roomTypes = [
    {
      "name": "Standard Room",
      "image": 'assets/images/standard_bedroom.jpg',
      "selected": false,
      "description": "Has a double bed, TV, and private bathroom.",
      "price": 80,
      "priceRange": [80, 120],
      "showDescription": false,
      "controller": TextEditingController()
    },
    {
      "name": "Deluxe Room",
      "image": 'assets/images/deluxe_bedroom.jpg',
      "selected": false,
      "description": "Includes a king bed, minibar, and a view of the city or garden.",
      "price": 120,
      "priceRange": [120, 180],
      "showDescription": false,
      "controller": TextEditingController()
    },
    {
      "name": "Junior Suite",
      "image": 'assets/images/junior_suite_bedroom.jpg',
      "selected": false,
      "description": "Offers a king bed, seating area, and large bathroom.",
      "price": 180,
      "priceRange": [180, 250],
      "showDescription": false,
      "controller": TextEditingController()
    },
    {
      "name": "Executive Suite",
      "image": 'assets/images/suite_executive.jpg',
      "selected": false,
      "description": "King bed, dedicated workspace, jacuzzi, and premium amenities.",
      "price": 250,
      "priceRange": [250, 350],
      "showDescription": false,
      "controller": TextEditingController()
    },
    {
      "name": "Penthouse",
      "image": 'assets/images/penthouse_room.jpg',
      "selected": false,
      "description": "Multiple rooms, kitchen, and panoramic views of the city or surroundings.",
      "price": 500,
      "priceRange": [500, 1000],
      "showDescription": false,
      "controller": TextEditingController()
    },
  ];

  void toggleSelection(int index) {
    setState(() {
      roomTypes[index]["selected"] = !roomTypes[index]["selected"];
    });
  }

  void toggleDescription(int index) {
    setState(() {
      roomTypes[index]["showDescription"] = !roomTypes[index]["showDescription"];
    });
  }

  Future<void> submitSelection() async {
    var isWrong = false;

    var clicked = false;

    int i = 1;

    String? hotelId = await _getLocality();

    for (var room in roomTypes.where((room) => room["selected"])) {
      double? enteredPrice = double.tryParse(room["controller"].text);
      if (enteredPrice != null &&
          enteredPrice >= room["priceRange"][0] &&
          enteredPrice <= room["priceRange"][1]) {
        clicked = true;
        await _commerceService.registerRoomTypes(room["name"], enteredPrice);

        await _monitoringService.createRoom(Room(id: 0, typeRoomId: i, hotelId: int.parse(hotelId!), roomState: 'LIBRE'));

        i += 1;
      } else {
        clicked = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Price for ${room["name"]} should be between ${room["priceRange"][0]} and ${room["priceRange"][1]}'),
        ));
        isWrong = true;
      }
    }

    if(!isWrong && clicked)
    {
      Navigator.pushNamed(context, '/worker-areas-selection');
    }
  }

  Future<String?> _getLocality() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();
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
    return BaseLayout(
      role: '',
      childScreen: getContentView()
    );
  }

  Widget getContentView()
  {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: roomTypes.length,
              itemBuilder: (context, index) {
                final room = roomTypes[index];
                return GestureDetector(
                  onTap: () => toggleSelection(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: AssetImage(room["image"]),
                                  fit: BoxFit.cover,
                                  colorFilter: room["selected"]
                                      ? ColorFilter.mode(
                                          Colors.black.withOpacity(0.6),
                                          BlendMode.srcATop)
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Text(
                                room["name"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  room["showDescription"]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.white,
                                ),
                                onPressed: () => toggleDescription(index),
                              ),
                            ),
                          ],
                        ),
                        if (room["showDescription"]) Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(room["description"]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: room["controller"],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Price',
                              hintText:
                                  'Range: \$${room["priceRange"][0]} - \$${room["priceRange"][1]}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: submitSelection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Siguiente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
    }
}
