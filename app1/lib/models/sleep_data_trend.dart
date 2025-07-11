class SleepDataTrend {
  final String time; // date in format yyyy-MM-dd
  final int duration; // sleep duration in minutes

  // Handles inconsistent API structures for the trend data
  static SleepDataTrend? fromApiData(String date, dynamic data) {
    // First case: the response is null
    if (data == null) return null;

    // Second case (most common format): the response format is List with inside a Map (as described in the API documentation)
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return SleepDataTrend.fromJson(date, data.first);
    }

    // Third case (less common format): the response format is a Map ---> examples: 29/04/2025 and 02/05/2025
    if (data is Map<String, dynamic>) {
      return SleepDataTrend.fromJson(date, data);
    }

    // In all other cases return null
    return null;
  }

  // Named constructor using an initializer list to extract values from JSON
  // [date] is passed from the outer structure (with the correct format yyyy-MM-dd)
  // [json] is the sleep data map containing the duration in ms
  SleepDataTrend.fromJson(String date, Map<String, dynamic> json)
      : time = date, // directly assign the provided date as the time
        duration = (json['duration'] ?? 0) ~/ 60000; // convert duration from ms to min

  @override
  String toString() {
    return 'SleepDataTrend(time: $time, duration: $duration minutes)';
  }
}
