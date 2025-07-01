import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math'; 

/// Generates 30 mock MealData entries for the past 30 days.
/// If available, sleep duration from individual night data is matched and attached.
Future<List<MealData>> generateMockMeals(SleepDataProvider sleepProvider) async {
  final List<MealData> mockMeals = [];
  final now = DateTime.now();
  
   final random = Random();

  // Loop through the last 30 days
  for (int i = 0; i < 30; i++) {
    final dateForMeal = now.subtract(Duration(days: i + 1));
    final formattedDateForMeal = DateFormat('yyyy-MM-dd').format(dateForMeal);

    // Generate mock meals that vary everyday
    late int carbs, fats, proteins;
    late String mealTypeString;

    // Randomly pick a meal archetype for the day to simulate different eating patterns
    int mealType = random.nextInt(4); // Generates a number from 0 to 3

    switch (mealType) {
      case 0:
        // Archetype 0: Balanced Meal
        mealTypeString = 'balanced';
        carbs = 100 + random.nextInt(51); // 100-150g
        fats = 40 + random.nextInt(31);  // 40-70g
        proteins = 50 + random.nextInt(31); // 50-80g
        break;
      case 1:
        // Archetype 1: High-Carb, Low-Fat Meal (e.g., Pasta Night)
        mealTypeString = 'highCarb';
        carbs = 180 + random.nextInt(71); // 180-250g
        fats = 20 + random.nextInt(21);   // 20-40g
        proteins = 40 + random.nextInt(21);  // 40-60g
        break;
      case 2:
        // Archetype 2: High-Fat, Low-Carb Meal (e.g., Keto-style)
        mealTypeString = 'highFat';
        carbs = 20 + random.nextInt(31);  // 20-50g
        fats = 70 + random.nextInt(41);   // 70-110g
        proteins = 60 + random.nextInt(31);  // 60-90g
        break;
      case 3:
        // Archetype 3: High-Protein Meal (e.g., Post-Workout)
        mealTypeString = 'highProtein';
        carbs = 80 + random.nextInt(51);  // 80-130g
        fats = 30 + random.nextInt(21);   // 30-50g
        proteins = 80 + random.nextInt(41);  // 80-120g
        break;
    }

    double? sleepHoursForThisMeal;

    try {
      // Fetch sleep data for the specific night corresponding to the meal date.
      // The Impact API's /sleep/.../day/{date}/ endpoint returns data for the sleep *ending* on the morning of {date}.
      // However, your MealData stores sleepHours for the night *after* the meal.
      // If meal.date is '2025-06-03', sleepHours is for the night of June 3rd to June 4th.
      // The sleep data for the night of 'formattedDateForMeal' (e.g., June 3rd)
      // would typically be available from an API endpoint queried with 'formattedDateForMeal'
      // or the next day 'June 4th' depending on how the API attributes the sleep session.

      // Let's assume your `fetchSleepNightData(dayString)` fetches sleep data for the night *starting* on `dayString`.
      // Your `SleepDataProvider.fetchSleepNightData(day)` updates `sleepProvider.sleepNightData`.
      await sleepProvider.fetchSleepNightData(formattedDateForMeal);

      // Check if the fetched data corresponds to the requested date and has a valid duration.
      // sleepProvider.sleepNightData will be null if the fetch failed or no data was returned.
      if (sleepProvider.sleepNightData != null && sleepProvider.sleepNightData!.time == formattedDateForMeal) {
        // Convert duration from minutes (as in SleepDataNight) to hours.
        // A duration of 0 from the API might mean no sleep was recorded or a very short sleep.
        // We'll treat 0 minutes as "Not yet recorded" for clarity in the diary.
        if (sleepProvider.sleepNightData!.duration > 0) {
          sleepHoursForThisMeal = sleepProvider.sleepNightData!.duration / 60.0;
        }
      }
    } catch (e) {
      // If there's an error fetching sleep data for a specific day (e.g., API error, no data),
      // print an error and leave sleepHoursForThisMeal as null.
      print('Could not fetch sleep data for $formattedDateForMeal: $e');
    }

    // Create the MealData object, optionally attaching sleep hours
    mockMeals.add(MealData(
      date: formattedDateForMeal,
      carbs: carbs,
      fats: fats,
      proteins: proteins,
      mealType: mealTypeString,
      sleepHours: sleepHoursForThisMeal, // Will be null if not found or if fetch failed
    ));
  }
  
  mockMeals.sort((a, b) => b.date.compareTo(a.date));
  
  return mockMeals;
}