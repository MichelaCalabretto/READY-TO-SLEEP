class MealData {
  /// Date of the meal in 'yyyy-MM-dd' format (same format used for sleep data)
  final String date;

  /// Macronutrient amounts in grams
  int carbs;
  int fats;
  int proteins;
  String mealType;

  /// Number of sleep hours recorded the night after the meal (null if not yet available)
  double? sleepHours;

  MealData({
    required this.date,
    required this.carbs,
    required this.fats,
    required this.proteins,
    required this.mealType,
    this.sleepHours, //sleepHours is optional, since it will be aviable only after the night passes
  });

  /// Returns true if sleep data has been recorded after this meal
  bool isSleepDataAvailable() {
    return sleepHours != null;
  }

  /// Convert object to a Map (for DB storage or serialization)
  Map<String, dynamic> toMap() => {
        'date': date,
        'carbs': carbs,
        'fats': fats,
        'proteins': proteins,
        'mealType': mealType,
        'sleepHours': sleepHours,
      };

  /// Create object from Map (from database)
  factory MealData.fromMap(Map<String, dynamic> map) => MealData( //factory also allows to return null or cache something
        date: map['date'],
        carbs: map['carbs'],
        fats: map['fats'],
        proteins: map['proteins'],
        mealType: map['mealType'] ?? 'unknown',
        sleepHours: map['sleepHours']?.toDouble(),
      );

  @override
  String toString() {
    return 'MealData(date: $date, carbs: $carbs g, fats: $fats g, proteins: $proteins g, '
        'mealType: $mealType, sleepHours: ${sleepHours?.toStringAsFixed(1) ?? "Not yet recorded"})';
  }
}
