import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/models/terminal.dart';
import 'package:fyp_admin_panel/models/terminal_location.dart';
import 'package:fyp_admin_panel/widgets/data_form.dart';
import 'package:fyp_admin_panel/widgets/form_text_field.dart';

import 'loading_indicator.dart';

class AddTerminalDisplay extends StatefulWidget {
  const AddTerminalDisplay({Key? key}) : super(key: key);

  @override
  State<AddTerminalDisplay> createState() => _AddTerminalDisplayState();
}

class _AddTerminalDisplayState extends State<AddTerminalDisplay> {
  late final Stream<QuerySnapshot> _terminalStream;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<String> _terminalIDs = [];
  final List<String> _terminalNames = [];

  void _allTerminals() {
    _terminalStream.listen((querySnapshot) {
      final List<QueryDocumentSnapshot> terminalDocs = querySnapshot.docs;
      for (var terminalDoc in terminalDocs) {
        _terminalIDs.add(terminalDoc['terminal_id'].toString());
        _terminalNames.add(terminalDoc['terminal_name']);
      }
    });
  }

  @override
  void initState() {
    _terminalStream = firestoreManager.getAllTerminals();
    _allTerminals();
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
                  _nameController.clear();
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
                    Text('New Terminal'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 9,
              child: StreamBuilder(
                stream: _terminalStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  final QuerySnapshot querySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> terminalDocs = querySnapshot.docs;
                  return ListView.builder(
                    itemCount: terminalDocs.length,
                    itemBuilder: (context, index) {
                      return Material(
                        child: ListTile(
                          tileColor: index % 2 == 0 ? Colors.grey[50] : Colors.grey[100],
                          title: Row(
                            children: [
                              const Text('Terminal Name:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text(terminalDocs[index]['terminal_name'].toString().toUpperCase(),
                                  style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              const Text('Terminal ID:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text('${terminalDocs[index]['terminal_id']}',
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
        title: const Text('Add new terminal'),
        content: SizedBox(
          width: 400.0,
          height: 280.0,
          child: DataForm(
            fields: [
              FormTextField(
                controller: _idController,
                hintText: 'Terminal ID',
                label: 'ID',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID cannot be null';
                  }
                  for (var id in _terminalIDs) {
                    if (value == id) {
                      return 'Terminal ID already exist!';
                    }
                  }
                  return null;
                },
              ),
              FormTextField(
                controller: _nameController,
                hintText: 'Terminal name',
                label: 'Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Terminal name cannot be null';
                  }
                  for (var name in _terminalNames) {
                    if (value.toLowerCase() == name.toLowerCase()) {
                      return 'Terminal name already exist!';
                    }
                  }
                  return null;
                },
              ),
            ],
            onPressed: () {
              firestoreManager.createTerminal(Terminal(
                terminalID: int.parse(_idController.text),
                terminalName: _nameController.text,
                totalRequests: 0,
                terminalLocation: const TerminalLocation(
                  latitude: 0.0,
                  longitude: 0.0,
                ),
                requests: [],
              ));
              return true;
            },
          ),
        ));
  }
}
