import 'package:intl/intl.dart';

class SleepDataTrend {
  final DateTime time;
  final int duration;


  SleepDataTrend({
    required this.time,
    required this.duration,

  });

  SleepDataTrend.fromJson(String date, Map<String, dynamic> json)
      : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
        duration = int.parse(json["duration"]);
        


  @override
  String toString() {
    return 'SleepDataTrend(time: $time, duration: $duration)';
  }
}