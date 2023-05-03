import 'package:fyp_admin_panel/models/request.dart';
import 'package:fyp_admin_panel/models/terminal_location.dart';

class Terminal {
  const Terminal({
    required this.terminalID,
    required this.terminalName,
    required this.totalRequests,
    required this.terminalLocation,
    required this.requests,
  });
  final int terminalID;
  final String terminalName;
  final TerminalLocation terminalLocation;
  final int totalRequests;
  final List<Request> requests;
}
