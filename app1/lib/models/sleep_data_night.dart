import 'package:intl/intl.dart';

class SleepDataNight {
  final DateTime time;
  final int duration;
  final int minutesToFallAsleep;
  final int minutesAwake;
  final int minutesAfterWakeUp;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;

  SleepDataNight({
    required this.time,
    required this.duration,
    required this.minutesToFallAsleep,
    required this.minutesAwake,
    required this.minutesAfterWakeUp,
    required this.deepMinutes,
    required this.lightMinutes,
    required this.remMinutes,
  });

  // Helper to safely parse int from dynamic
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  SleepDataNight.fromJson(String date, Map<String, dynamic> json)
      : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["startTime"] ?? "00:00:00"}'),
        duration = (_parseInt(json["duration"]) ~/ 60000), //ms to minutes ("~/"=integer division)
        minutesToFallAsleep = _parseInt(json["minutesToFallAsleep"]),
        minutesAwake = _parseInt(json["minutesAwake"]),
        minutesAfterWakeUp = _parseInt(json["minutesAfterWakeUp"]),
        deepMinutes = _parseInt(json["levels"]?["summary"]?["deep"]?["minutes"]?.toString()),
        lightMinutes = _parseInt(json["levels"]?["summary"]?["light"]?["minutes"]?.toString()),
        remMinutes = _parseInt(json["levels"]?["summary"]?["rem"]?["minutes"]?.toString());

  @override
  String toString() {
    return 'SleepDataNight(time: $time, duration: $duration, deep: $deepMinutes, light: $lightMinutes, rem: $remMinutes)';
  }
}
