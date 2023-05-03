import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/widgets/loading_indicator.dart';
import 'package:fyp_admin_panel/widgets/station_display.dart';

import 'display_badge.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final Stream<QuerySnapshot> _routeStream;
  late final Stream<QuerySnapshot> _driverStream;
  late final Stream<QuerySnapshot> _trashStream;
  late final Stream<QuerySnapshot> _terminalStream;

  @override
  void initState() {
    _terminalStream = firestoreManager.getAllTerminals();
    _routeStream = firestoreManager.getAllRoutes();
    _driverStream = firestoreManager.getAllDrivers();
    _trashStream = firestoreManager.getAllFromTrash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 6,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const StationDisplay(),
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: DisplayBadge(
                    color: Colors.grey[100] ?? Colors.white,
                    value: StreamBuilder<QuerySnapshot>(
                        stream: _terminalStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.data == null) {
                            return const LoadingIndicator();
                          }
                          final QuerySnapshot querySnapshot = snapshot.data!;
                          final List<QueryDocumentSnapshot> terminalDocs = querySnapshot.docs;
                          return Text(
                            '${terminalDocs.length}',
                            style: const TextStyle(
                              fontSize: 72.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                    title: 'Terminals',
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                    child: DisplayBadge(
                  color: Colors.grey[50] ?? Colors.white,
                  value: StreamBuilder<QuerySnapshot>(
                      stream: _routeStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.data == null) {
                          return const LoadingIndicator();
                        }
                        final QuerySnapshot querySnapshot = snapshot.data!;
                        final List<QueryDocumentSnapshot> routeDocs = querySnapshot.docs;
                        return Text(
                          '${routeDocs.length}',
                          style: const TextStyle(
                            fontSize: 72.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                  title: 'Routes',
                )),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DisplayBadge(
                    value: StreamBuilder<QuerySnapshot>(
                        stream: _driverStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.data == null) {
                            return const LoadingIndicator();
                          }
                          final QuerySnapshot querySnapshot = snapshot.data!;
                          final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
                          return Text(
                            '${driverDocs.length}',
                            style: const TextStyle(
                              fontSize: 72.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                    title: 'Drivers',
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DisplayBadge(
                    value: StreamBuilder(
                      stream: _trashStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.data == null) {
                          return const LoadingIndicator();
                        }
                        final QuerySnapshot querySnapshot = snapshot.data!;
                        final List<QueryDocumentSnapshot> historyDocs = querySnapshot.docs;
                        return Text(
                          '${historyDocs.length}',
                          style: const TextStyle(
                            fontSize: 72.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    title: 'Done Requests',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
