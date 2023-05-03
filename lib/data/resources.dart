import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fyp_admin_panel/data/firestore_manager.dart';

late FirestoreManager firestoreManager;
final datetimeNotifier = ValueNotifier<DateTime>(DateTime.now());
final selectedTerminalsNotifier = ValueNotifier<List<QueryDocumentSnapshot>>([]);
final selectedRoutesNotifier = ValueNotifier<List<QueryDocumentSnapshot>>([]);
