class Station {
  const Station({required this.stationID, required this.stationName, required this.routeRefs});
  final int stationID;
  final String stationName;
  final List<String> routeRefs;
}
