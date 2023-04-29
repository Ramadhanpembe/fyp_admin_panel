import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_admin_panel/models/terminal.dart';
import 'package:fyp_admin_panel/models/terminal_location.dart';

class FirestoreManager {
  late final FirebaseFirestore _db;

  FirestoreManager() {
    _init();
  }

  void _init() {
    _db = FirebaseFirestore.instance;
  }

  Stream<QuerySnapshot> getAvailableRoutes() {
    return _db.collection('routes').snapshots();
  }

  Stream<QuerySnapshot> getAvailableDrivers() {
    return _db.collection('drivers').snapshots();
  }

  Future<List<Terminal>> getAllTerminals() async {
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
        terminals.add(Terminal(
          terminalID: terminalDoc['terminal_id'],
          terminalName: terminalDoc['terminal_name'],
          terminalLocation: TerminalLocation(
            latitude: terminalDoc['terminal_location']['terminal_latitude'],
            longitude: terminalDoc['terminal_location']['terminal_longitude'],
          ),
          totalRequests: requestDocs.length,
        ));
      }
    }
    return terminals;
  }
}
