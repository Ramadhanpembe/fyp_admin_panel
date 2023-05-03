import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/models/terminal.dart';
import 'package:fyp_admin_panel/widgets/loading_indicator.dart';
import 'package:fyp_admin_panel/widgets/table_header.dart';

class TerminalComponent extends StatefulWidget {
  const TerminalComponent({Key? key}) : super(key: key);

  @override
  State<TerminalComponent> createState() => _TerminalComponentState();
}

class _TerminalComponentState extends State<TerminalComponent> {
  late final Future<List<Terminal>> _terminals;

  @override
  void initState() {
    _terminals = firestoreManager.getAvailableInRouteTerminals();
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
              title: 'Registered Terminals',
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<Terminal>>(
                future: _terminals,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  final List<Terminal> terminals = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Requests')),
                        DataColumn(label: Text('Latitude')),
                        DataColumn(label: Text('Longitude')),
                      ],
                      rows: _buildRows(terminals),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<DataRow> _buildRows(List<Terminal> terminals) {
    List<DataRow> rows = [];
    for (var terminal in terminals) {
      rows.add(DataRow(
        cells: _buildCells(terminal),
      ));
    }
    return rows;
  }

  List<DataCell> _buildCells(Terminal terminal) {
    return <DataCell>[
      DataCell(Text('${terminal.terminalID}')),
      DataCell(Text(terminal.terminalName)),
      DataCell(Text(
          '${terminal.totalRequests < 10 ? terminal.totalRequests.toString().padLeft(2, '0') : terminal.totalRequests}')),
      DataCell(Text('${terminal.terminalLocation.latitude}')),
      DataCell(Text('${terminal.terminalLocation.longitude}')),
    ];
  }
}
