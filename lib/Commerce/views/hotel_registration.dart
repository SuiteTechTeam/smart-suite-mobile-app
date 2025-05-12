import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/IAM/models/sign_in_entity.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart';
import 'package:sweetmanager/Profiles/hotels/models/hotel.dart';
import 'package:sweetmanager/Profiles/hotels/service/hotelservices.dart';
import 'package:sweetmanager/Profiles/hotels/view/hotelView.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class HotelRegistration extends StatefulWidget {
  const HotelRegistration({super.key, required this.credentials});

  final SignInEntity credentials;

  @override
  State<HotelRegistration> createState() => _HotelRegistrationState();
}

class _HotelRegistrationState extends State<HotelRegistration> {

  // Declare Services

  late SignInEntity credentials;

  final storage = const FlutterSecureStorage();

  final _hotelService = HotelService();

  final _authService = AuthService();

  // Declare all variables

  final TextEditingController _hotelNameController = TextEditingController();

  final TextEditingController _hotelAddressController = TextEditingController();

  final TextEditingController _contactController = TextEditingController();

  final TextEditingController _hotelDescriptionController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  Future<String?> _getIdentity() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }

  @override
  void initState() {
    
    super.initState();

    credentials = widget.credentials;
  }

  @override
  void dispose() {
    _hotelNameController.dispose();

    _hotelAddressController.dispose();

    _contactController.dispose();

    _hotelDescriptionController.dispose();

    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getIdentity(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator(),);
        }

        if(snapshot.hasData)
        {
          String identity = snapshot.data!;

          return BaseLayout(
            role: '',
            childScreen: getContentView(context, identity)
          );
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }


  Widget getContentView(BuildContext context, String identity)
  {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:  Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _hotelNameController, 
                    decoration: const InputDecoration(
                      labelText: 'Hotel Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 60,),
                  TextField(
                    controller: _hotelAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Hotel Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 60,),
                  TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Information',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 60,),
                  TextField(
                    controller: _hotelDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Hotel Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 60,),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 60,),
                  ElevatedButton(
                      onPressed: () async {
                        // Access cardIdentifier here
                        print('${_hotelNameController.text}');
                        print('${_hotelAddressController.text}');
                        print('${_contactController.text}');
                        print('${_hotelDescriptionController.text}');
                        print('${_emailController.text}');
                        
                        if(_hotelNameController.text.isEmpty || _hotelAddressController.text.isEmpty || _contactController.text.isEmpty || 
                            _hotelDescriptionController.text.isEmpty || _emailController.text.isEmpty)
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all the corresponding fields.'))
                                  );
                              return;
                            }

                        var hotel = Hotel(id: 0, name: _hotelNameController.text, address: _hotelAddressController.text, phoneNumber: int.parse(_contactController.text), 
                            email: _emailController.text, description: _hotelDescriptionController.text, ownerId: int.parse(identity));

                        var validation = await _hotelService.registerHotel(hotel);

                        if(validation != null)
                        {
                          await _authService.login(credentials.email, credentials.password, 1);

                          Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: validation)));
                        }
                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Couldnt create hotel'))
                                  );
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 16),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}