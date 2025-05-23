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

 
  SleepDataNight.fromJson(String date, Map<String, dynamic> json)
      : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
        duration = int.parse(json["duration"]),
        minutesToFallAsleep = int.parse(json["minutesToFallAsleep"]),
        minutesAwake = int.parse(json["minutesAwake"]),
        minutesAfterWakeUp = int.parse(json["minutesAfterWakeUp"]),
        deepMinutes = int.parse(json["deepMinutes"]),
        lightMinutes = int.parse(json["lightMinutes"]),
        remMinutes = int.parse(json["remMinutes"]);

  @override
  String toString() {
    return 'SleepDataNight(time: $time, duration: $duration, deep: $deepMinutes, light: $lightMinutes, rem: $remMinutes)';
  }
}