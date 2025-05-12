import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Commerce/widgets/bar_chart.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class DashboardScreen extends StatefulWidget{
  
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
{
  // Initializing variables
  final storage = const FlutterSecureStorage();

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
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator(),);
        }

        if(snapshot.hasData)
        {
          String? role = snapshot.data;

          return BaseLayout(
            role: role,
            childScreen: getContentView(role)
          );
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }
  
  Widget getContentView(String? role)
  {
    if (role == 'ROLE_ADMIN') {
      return BarChartTest(role: role!,);
    } else if (role == 'ROLE_WORKER') {
      return BarChartTest(role: role!,);
    } else if (role == 'ROLE_OWNER') {
      return BarChartTest(role: role!,);
    } else {
      return const Text('Check code');
    }
  }

}