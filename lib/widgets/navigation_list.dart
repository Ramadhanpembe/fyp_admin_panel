import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/widgets/navigation_button.dart';

import '../ui_builders/component_builder.dart';

class NavigationList extends StatefulWidget {
  const NavigationList({Key? key}) : super(key: key);

  @override
  State<NavigationList> createState() => _NavigationListState();
}

class _NavigationListState extends State<NavigationList> {
  int _selectedIndex = 0;
  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: navigators.length,
      itemBuilder: (context, index) {
        return NavigationButton(
          icon: navigators[index]['icon'],
          title: navigators[index]['name'],
          backgroundColor: _selectedIndex == index ? Colors.black : Colors.transparent,
          foregroundColor:
              _selectedIndex == index ? Colors.white : Colors.grey[700] ?? Colors.black54,
          onPressed: () {
            _onButtonPressed(index);
            indexValueNotifier.value = index;
          },
        );
      },
    );
  }
}
