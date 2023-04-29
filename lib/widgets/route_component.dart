import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/widgets/table_header.dart';

import '../data/resources.dart';
import 'loading_indicator.dart';

class RouteComponent extends StatefulWidget {
  const RouteComponent({Key? key}) : super(key: key);

  @override
  State<RouteComponent> createState() => _RouteComponentState();
}

class _RouteComponentState extends State<RouteComponent> {
  late final Stream<QuerySnapshot> _routeStream;

  @override
  void initState() {
    _routeStream = firestoreManager.getAvailableRoutes();
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
              title: 'Registered Routes',
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                  stream: _routeStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null) {
                      return const LoadingIndicator();
                    }
                    final QuerySnapshot routeQuerySnapshot = snapshot.data!;
                    final List<QueryDocumentSnapshot> routeDocs = routeQuerySnapshot.docs;
                    return InteractiveViewer(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Starting')),
                          DataColumn(label: Text('Ending')),
                          DataColumn(label: Text('Terminals')),
                        ],
                        rows: _buildRows(routeDocs),
                      ),
                    );
                  }),
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
    Stream<QuerySnapshot> terminalStream = doc.reference.collection('terminals').snapshots();
    return <DataCell>[
      DataCell(Text('${doc['from_terminal']} - ${doc['to_terminal']}')),
      DataCell(Text('${doc['from_terminal']}')),
      DataCell(Text('${doc['to_terminal']}')),
      DataCell(_terminalStreamBuilder(terminalStream)),
    ];
  }

  StreamBuilder<QuerySnapshot<Object?>> _terminalStreamBuilder(
      Stream<QuerySnapshot<Object?>> terminalStream) {
    return StreamBuilder(
      stream: terminalStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container();
        }
        final QuerySnapshot querySnapshot = snapshot.data!;
        return Text(
            '${querySnapshot.docs.length < 10 ? querySnapshot.docs.length.toString().padLeft(2, '0') : querySnapshot.docs.length}');
      },
    );
  }
}
