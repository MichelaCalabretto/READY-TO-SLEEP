import 'package:intl/intl.dart';

class SleepDataTrend {
  final DateTime time;
  final int duration;

  SleepDataTrend({
    required this.time,
    required this.duration,
  });

  // Helper to safely parse int from dynamic
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  SleepDataTrend.fromJson(Map<String, dynamic> json)
      : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse(json["time"]),
        duration = (_parseInt(json["duration"]) ~/ 60000); //ms to minutes ("~/"=integer division)

  @override
  String toString() {
    return 'SleepDataTrend(time: $time, duration: $duration)';
  }
}
