import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/widgets/component_a.dart';
import 'package:fyp_admin_panel/widgets/component_b.dart';
import 'package:fyp_admin_panel/widgets/driver_display.dart';
import 'package:fyp_admin_panel/widgets/home.dart';
import 'package:fyp_admin_panel/widgets/route_display.dart';

final indexValueNotifier = ValueNotifier<int>(0);
final List<Map<String, dynamic>> navigators = [
  {
    'icon': Icons.home,
    'name': 'Home',
    'ui': const Home(),
  },
  {
    'icon': Icons.add_location_alt_outlined,
    'name': 'Add terminal',
    'ui': const ComponentA(),
  },
  {
    'icon': Icons.add_road,
    'name': 'Add route',
    'ui': const ComponentB(),
  },
  {
    'icon': Icons.add_box,
    'name': 'Add station',
    'ui': const ComponentA(),
  },
  {
    'icon': Icons.view_array_outlined,
    'name': 'Routes',
    'ui': const RouteDisplay(),
  },
  {
    'icon': Icons.drive_eta_rounded,
    'name': 'Drivers',
    'ui': const DriverDisplay(),
  },
];
