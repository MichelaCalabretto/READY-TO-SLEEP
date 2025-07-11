class SleepDataNight {
  final String time; // the date of the night in yyyy-MM-dd format (from the button in the home page)
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

  // A static parsing utility that creates a SleepDataNight object from raw API data
  // It safely handles various response formats (List, Map, or null) before passing the data to the .fromJson constructor
  // The input fullDate is necessary to correctly handle the full date as yyyy-MM-dd (in the response the format is different)
  // The fullDate will then be passed to the fromJson to assign the correct date to the SleepDataNight object, along with the other parameters
  static SleepDataNight? fromApiData(String fullDate, dynamic data) {
    // First case: the response is null
    if (data == null) return null;

    // Second case (most common format): the response format is List with inside a Map (as described in the API documentation)
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) { // data is a List
                                                                                 // data.first is Map<...> ensures that the first element is a valid Map 
      return SleepDataNight.fromJson(fullDate, data.first);
    }

    // Third case (less common format): the response format is a Map ---> examples: 29/04/2025 and 02/05/2025
    if (data is Map<String, dynamic>) { 
      return SleepDataNight.fromJson(fullDate, data);
    }

    // In all other cases return null
    return null;
  }

  // Named constructor to create a SleepDataNight object from JSON-like data
  // [fullDate] is the full date string for the night in yyyy-MM-dd format
  // [json] is the sleep record map from the API (the fromJson will handle only Map formats, the variaty of the response is handled in the fromApiData)
  SleepDataNight.fromJson(String fullDate, Map<String, dynamic> json)
    // Initializer list ---> list of assignements to run before the main body of the constructor (in this case there is no body)
    : time = fullDate, // directly assign the provided date
      duration = (json['duration'] ?? 0) ~/ 60000, // convert duration from ms to minutes (~/ = integer division)
                                                   // check if the value is null through ?? and returns 0 if it is, then the division by 60000 is performed
      minutesToFallAsleep = json['minutesToFallAsleep'] ?? 0, // use 0 if the value is missing
      minutesAwake = json['minutesAwake'] ?? 0, 
      minutesRem = json['levels']?['summary']?['rem']?['minutes'] ?? 0, // safe access: if 'rem' or 'minutes' is missing, fallback to 0
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

