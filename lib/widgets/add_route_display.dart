import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/models/terminal_location.dart';

import '../data/resources.dart';
import '../models/route_info.dart';
import '../models/terminal.dart';
import 'data_form.dart';
import 'form_text_field.dart';
import 'loading_indicator.dart';

class AddRouteDisplay extends StatefulWidget {
  const AddRouteDisplay({Key? key}) : super(key: key);

  @override
  State<AddRouteDisplay> createState() => _AddRouteDisplayState();
}

class _AddRouteDisplayState extends State<AddRouteDisplay> {
  late final Stream<QuerySnapshot> _routeStream;
  final List<String> _routeIDs = [];
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  void _allRoutes() {
    _routeStream.listen((querySnapshot) {
      List<QueryDocumentSnapshot> routeDocs = querySnapshot.docs;
      for (var routeDoc in routeDocs) {
        _routeIDs.add(routeDoc['route_id'].toString());
      }
    });
  }

  @override
  void initState() {
    _routeStream = firestoreManager.getAllRoutes();
    _allRoutes();
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
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  _idController.clear();
                  _fromController.clear();
                  _toController.clear();
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => _showDialog(),
                  );
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add),
                    SizedBox(width: 8.0),
                    Text('New Route'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 9,
              child: StreamBuilder(
                stream: _routeStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  final QuerySnapshot querySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> routeDocs = querySnapshot.docs;
                  return ListView.builder(
                    itemCount: routeDocs.length,
                    itemBuilder: (context, index) {
                      return Material(
                        child: ListTile(
                          tileColor: index % 2 == 0 ? Colors.grey[50] : Colors.grey[100],
                          title: Row(
                            children: [
                              const Text('Route Name:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text(
                                  '${routeDocs[index]['from_terminal'].toString().toUpperCase()}'
                                  ' - ${routeDocs[index]['to_terminal'].toString().toUpperCase()}',
                                  style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              const Text('Route ID:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text('${routeDocs[index]['route_id']}',
                                  style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
        ],
      ),
    );
  }

  AlertDialog _showDialog() {
    return AlertDialog(
        title: const Text('Add new route'),
        content: SizedBox(
          width: 400.0,
          height: 380.0,
          child: DataForm(
            id: _idController.text,
            route: true,
            fields: [
              FormTextField(
                controller: _idController,
                hintText: 'Route ID',
                label: 'ID',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID cannot be null';
                  }
                  for (var id in _routeIDs) {
                    if (value == id) {
                      return 'RouteID ID already exist!';
                    }
                  }
                  return null;
                },
              ),
              FormTextField(
                controller: _fromController,
                hintText: 'Initial terminal name',
                label: 'Starts at',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Terminal name cannot be null';
                  }
                  return null;
                },
              ),
              FormTextField(
                controller: _toController,
                hintText: 'Final terminal name',
                label: 'Ends at',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Terminal name cannot be null';
                  }
                  return null;
                },
              ),
            ],
            onPressed: () {
              log('Length? ${selectedTerminalsNotifier.value.length}');
              final List<QueryDocumentSnapshot> selectedTerminalDocs =
                  selectedTerminalsNotifier.value;
              List<Terminal> terminals = [];
              for (var selectedTerminal in selectedTerminalDocs) {
                terminals.add(Terminal(
                  terminalID: selectedTerminal['terminal_id'],
                  terminalName: selectedTerminal['terminal_name'],
                  terminalLocation: TerminalLocation(
                      latitude: selectedTerminal['terminal_location']['terminal_latitude'],
                      longitude: selectedTerminal['terminal_location']['terminal_longitude']),
                  totalRequests: 0,
                  requests: [],
                ));
              }
              final String routeRef =
                  '@${_fromController.text.toUpperCase()}@${_toController.text.toUpperCase()}@';
              firestoreManager.createRoute(
                  routeRef: routeRef,
                  route: RouteInfo(
                    routeID: int.parse(_idController.text),
                    reference: routeRef,
                    fromTerminal: _fromController.text.toUpperCase(),
                    toTerminal: _toController.text.toUpperCase(),
                    routeTerminals: terminals,
                  ));
              return true;
            },
          ),
        ));
  }
}
