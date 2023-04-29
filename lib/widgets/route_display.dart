import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/widgets/route_component.dart';
import 'package:fyp_admin_panel/widgets/terminal_component.dart';

class RouteDisplay extends StatelessWidget {
  const RouteDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(
          child: RouteComponent(),
        ),
        SizedBox(
          height: 12.0,
        ),
        Expanded(
          child: TerminalComponent(),
        )
      ],
    );
  }
}
