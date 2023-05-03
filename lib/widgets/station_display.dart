import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/widgets/table_header.dart';

import '../models/terminal.dart';
import 'loading_indicator.dart';

class StationDisplay extends StatefulWidget {
  const StationDisplay({Key? key}) : super(key: key);

  @override
  State<StationDisplay> createState() => _StationDisplayState();
}

class _StationDisplayState extends State<StationDisplay> {
  late final Stream<QuerySnapshot> _stationStream;
  late QuerySnapshot query;

  @override
  void initState() {
    _stationStream = firestoreManager.getAllStations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: TableHeader(
              title: 'Registered Stations',
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: _stationStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }
                  final QuerySnapshot querySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> stationDocs = querySnapshot.docs;
                  return InteractiveViewer(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Routes')),
                        DataColumn(label: Text('Terminals')),
                      ],
                      rows: _buildRows(stationDocs),
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

  List<DataRow> _buildRows(List<QueryDocumentSnapshot> stationDocs) {
    List<DataRow> rows = [];
    for (var doc in stationDocs) {
      rows.add(DataRow(
        cells: _buildCells(doc),
      ));
    }

    return rows;
  }

  List<DataCell> _buildCells(QueryDocumentSnapshot doc) {
    Future<List<Terminal>> availableStationTerminals =
        firestoreManager.getAvailableStationTerminals(doc['station_id'].toString());
    return <DataCell>[
      DataCell(Text('${doc['station_id']}')),
      DataCell(Text('${doc['station_name']}')),
      DataCell(Text('${doc['route_list'].length}')),
      DataCell(_allTerminals(availableStationTerminals)),
    ];
  }

  FutureBuilder<List<Terminal>> _allTerminals(Future<List<Terminal>> availableStationTerminals) {
    return FutureBuilder<List<Terminal>>(
      future: availableStationTerminals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container();
        }
        return Text('${snapshot.data!.length}');
      },
    );
  }
}
