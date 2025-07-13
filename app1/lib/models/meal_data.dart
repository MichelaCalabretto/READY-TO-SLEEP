class MealData { 
  final String date; // date of the meal in 'yyyy-MM-dd' format
  int carbs; // macronutrient amounts in grams
  int fats;
  int proteins;
  String mealType;
  double? sleepHours; // number of sleep hours recorded the night after the meal (null if not yet available)

  MealData({
    required this.date,
    required this.carbs,
    required this.fats,
    required this.proteins,
    required this.mealType,
    this.sleepHours, //sleepHours is optional, since it will be aviable only after the night passes
  });

  // Returns true if sleep data has been recorded after this meal
  bool isSleepDataAvailable() {
    return sleepHours != null;
  }

  @override
  String toString() {
    return 'MealData(date: $date, carbs: $carbs g, fats: $fats g, proteins: $proteins g, '
        'mealType: $mealType, sleepHours: ${sleepHours?.toStringAsFixed(1) ?? "Not yet recorded"})'; // ?. because sleepHours could be null
                                                                                                     // .toStringAsFixed(1) converts the double into a String with just one decimal number (i.e. 7.5) 
  }
}
