import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';

import 'form_text_field.dart';
import 'loading_indicator.dart';

class DataForm extends StatefulWidget {
  const DataForm(
      {super.key,
      required this.fields,
      this.route = false,
      this.station = false,
      this.id = '0',
      required this.onPressed});

  final List<FormTextField> fields;
  final bool route;
  final bool station;
  final String id;
  final bool Function() onPressed;

  @override
  State<DataForm> createState() => _DataFormState();
}

class _DataFormState extends State<DataForm> {
  late final Stream<QuerySnapshot> _terminalStream;
  late final Stream<QuerySnapshot> _routeStream;
  final _formKey = GlobalKey<FormState>();
  List<bool?> _isChecked = [];
  List<QueryDocumentSnapshot> docs = [];

  @override
  void initState() {
    _terminalStream = firestoreManager.getAllTerminals();
    _routeStream = firestoreManager.getAllRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.fields,
            ),
            widget.route || widget.station
                ? Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  _showDialog(widget.route, widget.station, widget.id),
                            );
                          }
                        },
                        child: Text(widget.route ? 'Add Terminals' : 'Add routes'),
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 195.0,
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            bool success = widget.onPressed();
                            if (success) {
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('There was an error!'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                    SizedBox(
                      width: 195.0,
                      height: 40.0,
                      child: ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDialog(bool isRoute, bool isStation, String id) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isRoute ? 'Select Terminals' : 'Select Routes'),
          ElevatedButton(
            child: const Text('DONE'),
            onPressed: () {
              isRoute
                  ? selectedTerminalsNotifier.value = _selectedDocs
                  : selectedRoutesNotifier.value = _selectedDocs;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: StreamBuilder(
          stream: isRoute ? _terminalStream : _routeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
              return const LoadingIndicator();
            }

            final QuerySnapshot querySnapshot = snapshot.data!;
            docs = querySnapshot.docs;
            _isChecked = List.generate(docs.length, (index) => false);

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return Material(
                  child: StatefulBuilder(
                    builder: (context, StateSetter state) {
                      return CheckboxListTile(
                        visualDensity: VisualDensity.comfortable,
                        value: _isChecked[index],
                        checkColor: Colors.white,
                        activeColor: Colors.black,
                        title: Text(isRoute
                            ? docs[index]['terminal_name']
                            : '${docs[index]['from_terminal']} - ${docs[index]['to_terminal']}'),
                        onChanged: (bool? value) async {
                          if (isRoute) {
                            bool isPreAdded = false;
                            final QuerySnapshot routeQuerySnapshot =
                                await firestoreManager.getAvailableRoutes();
                            final List<QueryDocumentSnapshot> routeDocs = routeQuerySnapshot.docs;
                            for (var routeDoc in routeDocs) {
                              if (routeDoc['route_id'].toString() == id) {
                                final CollectionReference terminalColRef =
                                    routeDoc.reference.collection('terminals');
                                final QuerySnapshot terminalQuerySnapshot =
                                    await terminalColRef.get();
                                final List<QueryDocumentSnapshot> terminalDocs =
                                    terminalQuerySnapshot.docs;
                                for (var terminalDoc in terminalDocs) {
                                  if (terminalDoc['terminal_name'] ==
                                      docs[index]['terminal_name']) {
                                    state(() {
                                      isPreAdded = true;
                                    });
                                  }
                                }
                              }
                            }
                            state(() {
                              if (isPreAdded) {
                                _isChecked[index] = false;
                              } else {
                                _isChecked[index] = value;
                              }
                            });
                          }
                          if (isStation) {
                            bool isPreAdded = false;
                            final QuerySnapshot stationQuerySnapshot =
                                await firestoreManager.getAvailableStations();
                            final List<QueryDocumentSnapshot> stationDocs =
                                stationQuerySnapshot.docs;
                            for (var stationDoc in stationDocs) {
                              if (stationDoc['station_id'].toString() == id) {
                                final List<String> routeRefs = stationDoc['route_list'];

                                final QuerySnapshot routeQuerySnapshot =
                                    await firestoreManager.getAvailableRoutes();
                                final List<QueryDocumentSnapshot> routeDocs =
                                    routeQuerySnapshot.docs;
                                for (var routeDoc in routeDocs) {
                                  for (var routeRef in routeRefs) {
                                    if (routeDoc.id == routeRef) {
                                      state(() {
                                        isPreAdded = true;
                                      });
                                    }
                                  }
                                }
                              }
                            }
                            state(() {
                              if (isPreAdded) {
                                _isChecked[index] = false;
                              } else {
                                _isChecked[index] = value;
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<int> get _selectedIndices {
    List<int> indices = [];
    for (int i = 0; i < _isChecked.length; i++) {
      if (_isChecked[i]!) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<QueryDocumentSnapshot> get _selectedDocs {
    List<QueryDocumentSnapshot> selectedDocs = [];
    for (int index in _selectedIndices) {
      selectedDocs.add(docs[index]);
    }
    return selectedDocs;
  }
}
