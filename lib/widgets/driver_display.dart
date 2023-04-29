import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/widgets/loading_indicator.dart';
import 'package:fyp_admin_panel/widgets/table_header.dart';

class DriverDisplay extends StatefulWidget {
  const DriverDisplay({Key? key}) : super(key: key);

  @override
  State<DriverDisplay> createState() => _DriverDisplayState();
}

class _DriverDisplayState extends State<DriverDisplay> {
  late final Stream<QuerySnapshot> _driverStream;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _driverStream = firestoreManager.getAvailableDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: TableHeader(
              title: 'Registered Drivers',
            ),
          ),
          Expanded(
            flex: 7,
            child: SizedBox(
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: _driverStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  final QuerySnapshot driverQuerySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> driverDocs = driverQuerySnapshot.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Scrollbar(
                      controller: _controller,
                      child: SingleChildScrollView(
                        controller: _controller,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Username')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Route')),
                            DataColumn(label: Text('Requests')),
                            DataColumn(label: Text('Accepted')),
                            DataColumn(label: Text('Rejected')),
                            DataColumn(label: Text('Latitude')),
                            DataColumn(label: Text('Longitude')),
                          ],
                          rows: _buildRows(driverDocs),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildRows(List<QueryDocumentSnapshot> docs) {
    List<DataRow> rows = [];
    for (var doc in docs) {
      rows.add(DataRow(
        cells: _buildCells(doc),
      ));
    }
    return rows;
  }

  List<DataCell> _buildCells(QueryDocumentSnapshot doc) {
    final Stream<QuerySnapshot> messageStream = doc.reference.collection('messages').snapshots();
    final Stream<QuerySnapshot> responseStream = doc.reference.collection('responses').snapshots();
    return <DataCell>[
      DataCell(Text(doc['username'])),
      DataCell(Text(doc['login']['phone'])),
      DataCell(Text('${doc['route']['from_terminal']} - ${doc['route']['to_terminal']}')),
      DataCell(_requestBuilder(messageStream)),
      DataCell(_acceptedBuilder(responseStream)),
      DataCell(_rejectedBuilder(responseStream)),
      DataCell(Text('${doc['location']['latitude']}')),
      DataCell(Text('${doc['location']['longitude']}')),
    ];
  }

  StreamBuilder<QuerySnapshot> _requestBuilder(Stream<QuerySnapshot> messageStream) {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container();
        }

        final QuerySnapshot querySnapshot = snapshot.data!;
        final List<QueryDocumentSnapshot> messageDocs = querySnapshot.docs;
        return Text('${messageDocs.length}');
      },
    );
  }

  StreamBuilder<QuerySnapshot> _acceptedBuilder(Stream<QuerySnapshot> responseStream) {
    return StreamBuilder(
      stream: responseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container();
        }
        List<QueryDocumentSnapshot> acceptedResponses = [];
        final QuerySnapshot querySnapshot = snapshot.data!;
        final List<QueryDocumentSnapshot> responseDocs = querySnapshot.docs;
        for (var responseDoc in responseDocs) {
          if (responseDoc['is_accepted'] == true) {
            acceptedResponses.add(responseDoc);
          }
        }
        return Text('${acceptedResponses.length}');
      },
    );
  }

  StreamBuilder<QuerySnapshot> _rejectedBuilder(Stream<QuerySnapshot> responseStream) {
    return StreamBuilder(
      stream: responseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container();
        }
        List<QueryDocumentSnapshot> rejectedResponses = [];
        final QuerySnapshot querySnapshot = snapshot.data!;
        final List<QueryDocumentSnapshot> responseDocs = querySnapshot.docs;
        for (var responseDoc in responseDocs) {
          if (responseDoc['is_accepted'] == false) {
            rejectedResponses.add(responseDoc);
          }
        }
        return Text('${rejectedResponses.length}');
      },
    );
  }
}
