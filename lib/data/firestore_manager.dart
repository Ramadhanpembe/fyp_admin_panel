import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_admin_panel/models/route_info.dart';
import 'package:fyp_admin_panel/models/station.dart';
import 'package:fyp_admin_panel/models/terminal.dart';
import 'package:fyp_admin_panel/models/terminal_location.dart';

import '../models/request.dart';

class FirestoreManager {
  late final FirebaseFirestore _db;

  FirestoreManager() {
    _init();
  }

  void _init() {
    _db = FirebaseFirestore.instance;
  }

  void createTerminal(Terminal terminal) async {
    final CollectionReference terminalColRef = _db.collection('terminals');
    final DocumentReference terminalDocRef = terminalColRef.doc('@${terminal.terminalName}@');
    terminalDocRef.set({
      'terminal_id': terminal.terminalID,
      'terminal_name': terminal.terminalName,
      'terminal_location': {
        'terminal_latitude': terminal.terminalLocation.latitude,
        'terminal_longitude': terminal.terminalLocation.longitude,
      }
    });
  }

  Stream<QuerySnapshot> getAllStations() {
    return _db.collection('stations').snapshots();
  }

  Stream<QuerySnapshot> getAllRoutes() {
    return _db.collection('routes').snapshots();
  }

  Future<QuerySnapshot> getAvailableRoutes() async {
    return await _db.collection('routes').get();
  }

  Future<QuerySnapshot> getAvailableStations() async {
    return await _db.collection('stations').get();
  }

  Stream<QuerySnapshot> getAllDrivers() {
    return _db.collection('drivers').snapshots();
  }

  Stream<QuerySnapshot> getAllFromTrash() {
    return _db.collection('trash').snapshots();
  }

  Stream<QuerySnapshot> getAllTerminals() {
    return _db.collection('terminals').snapshots();
  }

  /// DONE! Works perfectly!!
  Future<List<Terminal>> getAvailableInRouteTerminals() async {
    List<Terminal> terminals = [];
    final CollectionReference routeColRef = _db.collection('routes');
    final QuerySnapshot routeQuerySnapshot = await routeColRef.get();
    final List<QueryDocumentSnapshot> routeDocs = routeQuerySnapshot.docs;

    for (var routeDoc in routeDocs) {
      final CollectionReference terminalColRef = routeDoc.reference.collection('terminals');
      final QuerySnapshot terminalQuerySnapshot = await terminalColRef.get();
      final List<QueryDocumentSnapshot> terminalDocs = terminalQuerySnapshot.docs;
      for (var terminalDoc in terminalDocs) {
        final CollectionReference requestColRef = terminalDoc.reference.collection('requests');
        final QuerySnapshot requestQuerySnapshot = await requestColRef.get();
        final List<QueryDocumentSnapshot> requestDocs = requestQuerySnapshot.docs;

        final bool exist = _containsTerminalID(terminals, terminalDoc['terminal_id']);
        if (!exist) {
          terminals.add(Terminal(
            terminalID: terminalDoc['terminal_id'],
            terminalName: terminalDoc['terminal_name'],
            terminalLocation: TerminalLocation(
              latitude: terminalDoc['terminal_location']['terminal_latitude'],
              longitude: terminalDoc['terminal_location']['terminal_longitude'],
            ),
            totalRequests: requestDocs.length,
            requests: [],
          ));
        }
      }
    }
    return terminals;
  }

  Future<List<Terminal>> getAvailableStationTerminals(String stationID) async {
    List<Terminal> terminals = [];
    List<Request> requests = [];

    List<QueryDocumentSnapshot> stationRouteDocs = [];
    List<String> routeRefs = [];
    final CollectionReference stationColeRef = _db.collection('stations');
    final QuerySnapshot stationQuerySnapshot = await stationColeRef.get();
    final List<QueryDocumentSnapshot> stationDocs = stationQuerySnapshot.docs;
    for (var stationDoc in stationDocs) {
      if (stationDoc['station_id'].toString() == stationID) {
        for (var route in stationDoc['route_list']) {
          routeRefs.add(route);
        }
      }
    }
    final CollectionReference routeColRef = _db.collection('routes');
    final QuerySnapshot routeQuerySnapshot = await routeColRef.get();
    final List<QueryDocumentSnapshot> routeDocs = routeQuerySnapshot.docs;

    for (var element in routeDocs) {
      for (var routeRef in routeRefs) {
        if (element.id == routeRef) {
          stationRouteDocs.add(element);
        }
      }
    }

    for (var stationRouteDoc in stationRouteDocs) {
      final CollectionReference terminalColRef = stationRouteDoc.reference.collection('terminals');
      final QuerySnapshot terminalQuerySnapshot = await terminalColRef.get();
      final List<QueryDocumentSnapshot> terminalDocs = terminalQuerySnapshot.docs;
      for (var terminalDoc in terminalDocs) {
        final CollectionReference requestColRef = terminalDoc.reference.collection('requests');
        final QuerySnapshot requestQuerySnapshot = await requestColRef.get();
        final List<QueryDocumentSnapshot> requestDocs = requestQuerySnapshot.docs;
        for (var requestDoc in requestDocs) {
          requests.add(Request(
            requestTime: requestDoc['request_time'],
          ));
        }
        terminals.add(Terminal(
          terminalID: terminalDoc['terminal_id'],
          terminalName: terminalDoc['terminal_name'],
          terminalLocation: TerminalLocation(
            latitude: terminalDoc['terminal_location']['terminal_latitude'],
            longitude: terminalDoc['terminal_location']['terminal_longitude'],
          ),
          totalRequests: requestDocs.length,
          requests: requests,
        ));
      }
    }
    return terminals;
  }

  /// we need to have a method that will create new station.
  /// Stations aim to display routes that are only available
  /// at a particular main bus station
  void createStation(Station station) async {
    final CollectionReference stationColRef = _db.collection('stations');
    final QuerySnapshot stationQuerySnapshot = await stationColRef.get();
    final List<QueryDocumentSnapshot> stationDocs = stationQuerySnapshot.docs;
    for (var stationDoc in stationDocs) {
      if (stationDoc['station_id'] == station.stationID) return;
    }
    await stationColRef.add({
      'station_id': station.stationID,
      'station_name': station.stationName,
      'route_list': station.routeRefs,
    });
  }

  void createRoute({required String routeRef, required RouteInfo route}) async {
    final CollectionReference routesColRef = _db.collection('routes');
    final DocumentReference mainDocRef = routesColRef.doc(routeRef);
    await mainDocRef.set({
      'route_id': route.routeID,
      'from_terminal': route.fromTerminal,
      'to_terminal': route.toTerminal,
    });

    final CollectionReference terminalColRef = mainDocRef.collection('terminals');
    for (var terminal in route.routeTerminals) {
      final DocumentReference terminalDocRef = terminalColRef.doc('@${terminal.terminalName}@');
      terminalDocRef.set({
        'terminal_id': terminal.terminalID,
        'terminal_name': terminal.terminalName,
        'terminal_location': {
          'terminal_latitude': terminal.terminalLocation.latitude,
          'terminal_longitude': terminal.terminalLocation.longitude,
        }
      });
      final CollectionReference requestColRef = terminalDocRef.collection('requests');
      for (var request in terminal.requests) {
        final DocumentReference requestDocRef = requestColRef.doc(
            '@${terminal.terminalName}@${DateTime.now().millisecondsSinceEpoch}@${Random.secure().nextInt(100)}@');
        requestDocRef.set({'request_time': request.requestTime});
      }
    }
  }

  bool _containsTerminalID(List<Terminal> terminals, int id) {
    return terminals.any((element) => element.terminalID == id);
  }
}
