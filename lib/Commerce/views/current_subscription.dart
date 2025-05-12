
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Commerce/models/contract_owners.dart';
import 'package:sweetmanager/Commerce/services/subscription_service.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class CurrentSubscription extends StatefulWidget {
  const CurrentSubscription({super.key});

  @override
  State<CurrentSubscription> createState() => _CurrentSubscriptionState();
}

class _CurrentSubscriptionState extends State<CurrentSubscription> {

  final subscriptionService = SubscriptionService();

  final storage = const FlutterSecureStorage();

  late ContractOwners? contractFetched;

  late String startDate;

  late String endDate;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> _getIdentity() async
  {
    // Retrieve token from local storage

    String? token = await storage.read(key: 'token');

    Map<String,dynamic> decodedToken = JwtDecoder.decode(token!);

    // Get Role in Claims token

    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']?.toString();
  }

  Future<String?> _getRole() async
  {
    // LOAD Data
    var id = await _getIdentity();

    contractFetched = await subscriptionService.fetchContractByOwnerId(int.parse(id!));

    // Start Date
    DateTime startParsedDate = DateTime.parse(contractFetched!.startDate);

    startDate = DateFormat('yyyy-MM-dd').format(startParsedDate);

    // End Date
    DateTime endParsedDate = DateTime.parse(contractFetched!.finalDate);

    endDate = DateFormat('yyyy-MM-dd').format(endParsedDate);

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
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.hasData)
        {
          String? role = snapshot.data;

          return BaseLayout(
            role: role,
            childScreen: getContentView()
          );
        }
        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }

  Widget getContentView()
  {
    if(contractFetched!.subscriptionId == 1)
    {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plan Details
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "BASIC PLAN",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.check, color: Colors.blue),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Monthly • Basic Plan",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$29.50/month",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Expiration Date
              buildInfoCard("Fecha de expiración", endDate, Colors.blue[900]!),
              const SizedBox(height: 8),
              // Start Date
              buildInfoCard("Fecha de inicio", startDate, Colors.lightBlue),
              const SizedBox(height: 8),
              // Status
              buildInfoCard("Estado", contractFetched!.status, Colors.lightBlue, isStatus: true),
              const SizedBox(height: 16),
              // Reminder
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reminder",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your plan will expire in 5 days. Renew now to avoid any interruptions in service!",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    else if(contractFetched!.subscriptionId == 2)
    {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plan Details
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "REGULAR PLAN",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.check, color: Colors.blue),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Monthly • Regular Plan",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$58.99/month",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Expiration Date
              buildInfoCard("Fecha de expiración", endDate, Colors.blue[900]!),
              const SizedBox(height: 8),
              // Start Date
              buildInfoCard("Fecha de inicio", startDate, Colors.lightBlue),
              const SizedBox(height: 8),
              // Status
              buildInfoCard("Estado", contractFetched!.status, Colors.lightBlue, isStatus: true),
              const SizedBox(height: 16),
              // Reminder
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reminder",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your plan will expire in 5 days. Renew now to avoid any interruptions in service!",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    else
    {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plan Details
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "PREMIUM PLAN",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.check, color: Colors.blue),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Monthly • Premium Plan",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$110.69/month",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Expiration Date
              buildInfoCard("Fecha de expiración", endDate, Colors.blue[900]!),
              const SizedBox(height: 8),
              // Start Date
              buildInfoCard("Fecha de inicio", startDate, Colors.lightBlue),
              const SizedBox(height: 8),
              // Status
              buildInfoCard("Estado", contractFetched!.status, Colors.lightBlue, isStatus: true),
              const SizedBox(height: 16),
              // Reminder
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reminder",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your plan will expire in 5 days. Renew now to avoid any interruptions in service!",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget buildInfoCard(String title, String value, Color color, {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

}