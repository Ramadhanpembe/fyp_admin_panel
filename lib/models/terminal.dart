import 'package:fyp_admin_panel/models/terminal_location.dart';

class Terminal {
  const Terminal(
      {required this.terminalID,
      required this.terminalName,
      required this.totalRequests,
      required this.terminalLocation});
  final int terminalID;
  final String terminalName;
  final TerminalLocation terminalLocation;
  final int totalRequests;
}
