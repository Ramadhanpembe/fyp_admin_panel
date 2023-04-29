import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/firestore_manager.dart';
import 'package:fyp_admin_panel/data/resources.dart';
import 'package:fyp_admin_panel/widgets/navigation_list.dart';

import '../ui_builders/component_builder.dart';
import '../widgets/holder.dart';
import '../widgets/logo.dart';

class Parent extends StatefulWidget {
  const Parent({Key? key}) : super(key: key);

  @override
  State<Parent> createState() => _ParentState();
}

class _ParentState extends State<Parent> {
  @override
  void initState() {
    firestoreManager = FirestoreManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double height = constraints.maxHeight;
              return Container(
                color: Colors.grey[300],
                height: MediaQuery.of(context).size.height,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        margin: const EdgeInsets.fromLTRB(24.0, 12.0, 6.0, 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                            child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Logo(
                                  fontSize: _fontSize(height),
                                ),
                              ),
                              const Expanded(
                                flex: 7,
                                child: NavigationList(),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Holder(
                          child: ValueListenableBuilder(
                        valueListenable: indexValueNotifier,
                        builder: (_, index, __) {
                          return navigators[index]['ui'];
                        },
                      )),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _fontSize(double height) {
    if (height >= 875) {
      return 22.0;
    } else if (height >= 735) {
      return 14.0;
    } else if (height >= 655) {
      return 12.0;
    } else {
      return 8.0;
    }
  }
}
