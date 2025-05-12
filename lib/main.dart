import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sweetmanager/Commerce/views/current_subscription.dart';
import 'package:sweetmanager/Commerce/views/dashboard.dart';
import 'package:sweetmanager/Commerce/views/worker_areas.dart';
import 'package:sweetmanager/Communication/views/messageScreen.dart';
import 'package:sweetmanager/Communication/views/notificationScreen.dart';
import 'package:sweetmanager/IAM/views/home.dart';
import 'package:sweetmanager/IAM/views/login.dart';
import 'package:sweetmanager/Monitoring/views/tablebooking.dart';
import 'package:sweetmanager/Monitoring/views/tableroom.dart';
import 'package:sweetmanager/Profiles/admins/views/management_admin_page.dart';
import 'package:sweetmanager/Profiles/customers/views/management_customer_page.dart';
import 'package:sweetmanager/Profiles/providers/views/management_provider_page.dart';
import 'package:sweetmanager/Profiles/views/profile.dart';
import 'package:sweetmanager/Profiles/workers/views/management_worker_page.dart';
import 'package:sweetmanager/ResourceManagement/pages/reportlist.dart';
import 'package:sweetmanager/supply-management/views/inventorymanagement.dart';
import 'package:sweetmanager/Communication/views/writeMessage.dart';
import 'package:sweetmanager/Communication/views/alertScreen.dart';
import 'package:sweetmanager/Communication/views/writeAlert.dart';
import 'firebase_options.dart'; // Import the generated options


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializa Firebase con la configuración correcta para la web
  /*await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBTGEj8JZrWvn62ZtofnaGr-LluqliNXMc",
      authDomain: "sweet-solutions.firebaseapp.com",
      projectId: "sweet-solutions",
      storageBucket: "sweet-solutions.appspot.com",
      messagingSenderId: "180154492305",
      appId: "1:180154492305:web:b156d317f56c1d4f34a630",
    ),
  );*/

  runApp(const MyHomePage());

}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeView(), 
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeView(), // the default app's entry point 
        '/login': (context) => const LogInScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/subscription': (context) => const SubscriptionPlansView(),
        '/rooms': (context) => const TableRoom(),
        '/providers': (context) => const ProvidersManagement(),
        // ignore: prefer_const_constructors
        '/supplies': (context) => InventoryManagement() ,
        '/messages': (context) => MessagesScreen(),
        // ignore: prefer_const_constructors
        '/reports': (context) => ReportList(),
        '/profiles': (context) => ProfilePage(),
        '/writemessage': (context) => WriteMessage(),
        '/alerts': (context) => const AlertsScreen(),
        '/writealert': (context) => WriteAlertScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/worker-areas-selection': (context) => const WorkerAreasSelection(),
        '/bookings': (context) => const TableBooking(),
        '/admins-management': (context) => const AdminManagement(),
        '/workers-management': (context) => const WorkerManagement(),
        '/customers-management': (context) => const CustomersManagement(),
        '/current-subscription': (context) => const CurrentSubscription(),
      },
    );
  }
}
