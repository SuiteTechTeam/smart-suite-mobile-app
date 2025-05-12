import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Monitoring/components/detailbooking.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

import '../components/editbookingdialog.dart';
import '../components/addbookingform.dart';
import '../models/booking.dart';
import '../services/bookingservice.dart';

class TableBooking extends StatefulWidget {

  const TableBooking({super.key});

  @override
  _TableBooking createState() => _TableBooking();
}

class _TableBooking extends State<TableBooking> {

  final storage = const FlutterSecureStorage();

  late Future<String?> fRole;
  late Future<String?> fHotelId;

  late String? role;
  late String? hotelId;
  late DataTableBooking dataTableSource;

  @override
  void initState() {
    super.initState();

    fRole = _getRole();
    fHotelId = _getHotelId();

    _getRole().then((roleValue) {
      setState(() {
        role = roleValue;
      });
    });

    _getHotelId().then((hotelIdValue) {
      setState(() {
        hotelId = hotelIdValue;
      });
    });
  }

  Future<String?> _getRole() async {
    String? token = await storage.read(key: 'token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();
  }

  Future<String?> _getHotelId() async {
    String? token = await storage.read(key: 'token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();
  }

  void _refreshTable() {
    setState(() {

      _getRole().then((roleValue) {
        setState(() {
          role = roleValue;
        });
      });

      _getHotelId().then((hotelIdValue) {
        setState(() {
          hotelId = hotelIdValue;
        });
      });

      dataTableSource = DataTableBooking
        (context, hotelId!, role == 'ROLE_WORKER');
    });
  }

  Widget getContentView(BuildContext context, String hotelId, String? role) {

    bool isWorker = role == 'ROLE_WORKER';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (isWorker)
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddBookingForm()),
                      );

                      if (result == true) {
                        _refreshTable();
                      }
                    },
                    child: const Text('Add booking'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable(
                header: const Text('Bookings'),
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return Colors.blue[800]!;
                  },
                ),
                rowsPerPage: 7,
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('ClientId')),
                  DataColumn(label: Text('RoomId')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('StartDate')),
                  DataColumn(label: Text('FinalDate')),
                  DataColumn(label: Text('State')),
                  DataColumn(label: Text('Options')),
                ],
                source: DataTableBooking(context, hotelId, isWorker),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([fRole, fHotelId]),
      builder: (context, AsyncSnapshot<List<String?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          String? role = snapshot.data![0];
          String? hotelId = snapshot.data![1];

          dataTableSource = DataTableBooking(context, hotelId!, role == 'ROLE_WORKER');

          return BaseLayout(role: role, childScreen: getContentView(context, hotelId, role));
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center));
      },
    );
  }
}

class DataTableBooking extends DataTableSource {

  late BookingService bookingService;
  late List<Booking> _data = [];
  final BuildContext context;
  final String hotelId;
  final bool isWorker;

  DataTableBooking(this.context, this.hotelId, this.isWorker) {

    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    bookingService = BookingService();
    _data = await bookingService.getBookingsByHotelId(hotelId);
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final data = _data[index];

    return DataRow(cells: [
      DataCell(Text(data.id.toString())),
      DataCell(Text(data.paymentCustomerId.toString())),
      DataCell(Text(data.roomId.toString())),
      DataCell(Text(data.description)),
      DataCell(Text(data.startDate.toString())),
      DataCell(Text(data.finalDate.toString())),
      DataCell(Text(data.bookingState)),
      DataCell(isWorker ? Row(
        children: [
          TextButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditBookingDialog(
                    id: data.id,
                    bookingState: data.bookingState,
                  );},
              );
              if (result == true) {
                _fetchBookings();
              }},
            child: const Text('Modify'),
          ),
          TextButton(
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context) {
                return DetailBooking(id: data.id);
              });
            },
            child: const Text('Detail'),
          ),
        ]) : const Text('No permitted'),
      )
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}