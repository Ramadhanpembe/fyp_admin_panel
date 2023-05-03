import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/models/station.dart';

import 'data_form.dart';
import 'form_text_field.dart';
import 'loading_indicator.dart';

class AddStationDisplay extends StatefulWidget {
  const AddStationDisplay({Key? key}) : super(key: key);

  @override
  State<AddStationDisplay> createState() => _AddStationDisplayState();
}

class _AddStationDisplayState extends State<AddStationDisplay> {
  late final Stream<QuerySnapshot> _stationStream;
  final List<String> _stationIDs = [];
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _allStations() {
    _stationStream.listen((querySnapshot) {
      List<QueryDocumentSnapshot> stationDocs = querySnapshot.docs;
      for (var stationDoc in stationDocs) {
        _stationIDs.add(stationDoc['station_id'].toString());
      }
    });
  }

  @override
  void initState() {
    _stationStream = firestoreManager.getAllStations();
    _allStations();
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
                    Text('New Station'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 9,
              child: StreamBuilder(
                stream: _stationStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  final QuerySnapshot querySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> stationDocs = querySnapshot.docs;
                  return ListView.builder(
                    itemCount: stationDocs.length,
                    itemBuilder: (context, index) {
                      return Material(
                        child: ListTile(
                          tileColor: index % 2 == 0 ? Colors.grey[50] : Colors.grey[100],
                          title: Row(
                            children: [
                              const Text('Station Name:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text(stationDocs[index]['station_name'].toString().toUpperCase(),
                                  style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              const Text('Station ID:', style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8.0),
                              Text('${stationDocs[index]['station_id']}',
                                  style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ))
        ],
      ),
    );
  }

  AlertDialog _showDialog() {
    return AlertDialog(
        title: const Text('Add new station'),
        content: SizedBox(
          width: 400.0,
          height: 300.0,
          child: DataForm(
            id: _idController.text,
            station: true,
            fields: [
              FormTextField(
                controller: _idController,
                hintText: 'Station ID',
                label: 'ID',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID cannot be null';
                  }
                  for (var id in _stationIDs) {
                    if (value == id) {
                      return 'StationID ID already exist!';
                    }
                  }
                  return null;
                },
              ),
              FormTextField(
                controller: _nameController,
                hintText: 'Station name',
                label: 'Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Station name cannot be null';
                  }
                  return null;
                },
              ),
            ],
            onPressed: () {
              log('Length? ${selectedRoutesNotifier.value.length}');

              final List<String> selectedRouteRefs = [];
              final List<QueryDocumentSnapshot> selectedRouteDocs = selectedRoutesNotifier.value;
              for (var routeDoc in selectedRouteDocs) {
                selectedRouteRefs.add(routeDoc.id);
              }

              firestoreManager.createStation(Station(
                stationID: int.parse(_idController.text),
                stationName: _nameController.text.toUpperCase(),
                routeRefs: selectedRouteRefs,
              ));
              return true;
            },
          ),
        ));
  }
}
