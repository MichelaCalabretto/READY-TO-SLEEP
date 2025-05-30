import 'package:intl/intl.dart';

class SleepDataNight {
  final String time; /// the date of the night in yyyy-MM-dd format (from the button in the home page).
  final int duration;
  final int minutesToFallAsleep;
  final int minutesAwake;
  final int minutesRem;
  final int minutesDeep;
  final int minutesLight;

  SleepDataNight({
    required this.time,
    required this.duration,
    required this.minutesToFallAsleep,
    required this.minutesAwake,
    required this.minutesRem,
    required this.minutesDeep,
    required this.minutesLight,
  });

  /// Factory method that safely parses inconsistent 'data' formats (ometimes 'data' ia a Map, sometimes a List of Maps, sometimes it's empty or malformed)
  /// factory constructor can return a new instance of a class, and can include logic or conditions before deciding what to return; it also doesn't need to create a new object every time
  static SleepDataNight? fromApiData(String fullDate, dynamic data) {
    if (data == null) return null;

    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) { //data is a List
                                                                                 //data.first is Map<...> ensures that the first element is a valid Map
      return SleepDataNight.fromJson(fullDate, data.first);
    }

    if (data is Map<String, dynamic>) { //data is already a single Map, and not inside a List
      return SleepDataNight.fromJson(fullDate, data);
    }

    return null;
  }

  /// Constructor to create a SleepDataNight object from JSON-like data
  /// - [fullDate] is the full date string for the night in yyyy-MM-dd format
  /// - [json] is the sleep record map from the API
  SleepDataNight.fromJson(String fullDate, Map<String, dynamic> json)
    : time = fullDate, // Directly assign the provided date
      duration = (json['duration'] ?? 0) ~/ 60000, // Convert duration from ms to minutes (~/ = integer division)
      minutesToFallAsleep = json['minutesToFallAsleep'] ?? 0, // Use 0 if the value is missing
      minutesAwake = json['minutesAwake'] ?? 0, 
      minutesRem = json['levels']?['summary']?['rem']?['minutes'] ?? 0, // Safe access: if 'rem' or 'minutes' is missing, fallback to 0
      minutesDeep = json['levels']?['summary']?['deep']?['minutes'] ?? 0, 
      minutesLight = json['levels']?['summary']?['light']?['minutes'] ?? 0; 

  @override
  String toString() {
    return 'SleepDataNight(time: $time, duration: $duration min, '
           'minutesToFallAsleep: $minutesToFallAsleep min, '
           'minutesAwake: $minutesAwake min, minutesRem: $minutesRem min, '
           'minutesDeep: $minutesDeep min, minutesLight: $minutesLight min)';
  }
}

