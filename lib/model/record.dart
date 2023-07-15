class Record {
  final int timestamp;
  final double value;

  Record({required this.timestamp, required this.value});

  DateTime getTime() {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
}

// Map<String, List<Record>> normalizeSeries(Map<String, List<Record>> raw, DateTime from, DateTime to, Duration step) {
//   DateTime current = from;
//   while (current.isBefore(to)) {
//
//     current.add(step);
//   }
// }