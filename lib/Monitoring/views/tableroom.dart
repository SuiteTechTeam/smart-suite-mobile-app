import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

import '../components/editroomdialog.dart';
import '../components/addroomdialog.dart';
import '../models/room.dart';
import '../services/roomservice.dart';

class TableRoom extends StatefulWidget {

  const TableRoom({super.key});

  @override
  _TableRoomState createState() => _TableRoomState();
}

class _TableRoomState extends State<TableRoom> {

  final storage = const FlutterSecureStorage();

  late Future<String?> fRole;
  late Future<String?> fHotelId;

  late String? role;
  late String? hotelId;
  late DataTableRoom dataTableSource;

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

      dataTableSource = DataTableRoom
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
                  'Room Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddRoomDialog();
                      },
                    );

                    if (result == true) {
                      _refreshTable();
                    }
                  },
                  child: const Text('Add room'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable(
                header: const Text('Rooms'),
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return Colors.blue[800]!;
                  },
                ),
                rowsPerPage: 7,
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Type room')),
                  DataColumn(label: Text('Hotel')),
                  DataColumn(label: Text('State')),
                  DataColumn(label: Text('Options')),
                ],
                source: dataTableSource,
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

          dataTableSource = DataTableRoom(context, hotelId!, role == 'ROLE_WORKER');

          return BaseLayout(role: role, childScreen: getContentView(context, hotelId, role));
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center));
      },
    );
  }
}

class DataTableRoom extends DataTableSource {

  late RoomService roomService;
  late List<Room> _data = [];
  final BuildContext context;
  final String hotelId;
  final bool isWorker;

  DataTableRoom(this.context, this.hotelId, this.isWorker) {

    _fetchRooms();
  }

  Future<void> _fetchRooms() async {

    roomService = RoomService();
    _data = await roomService.getRooms(hotelId);
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final data = _data[index];

    return DataRow(cells: [
      DataCell(Text(data.id.toString())),
      DataCell(Text(data.typeRoomId.toString())),
      DataCell(Text(data.hotelId.toString())),
      DataCell(Text(data.roomState.toString())),
      DataCell(isWorker ? TextButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditRoomDialog(
                id: data.id,
                typeRoomId: data.typeRoomId,
                hotelId: data.hotelId,
                roomState: data.roomState,
              );
            },
          );

          if (result == true){
            _fetchRooms();
          }
        },
        child: const Text('Modifier'),
      ) : const Text('No permitted'))
    ]);
  }


  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}