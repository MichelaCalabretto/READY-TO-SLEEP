import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // for the random generator

// Generates a List of MealData objects that will be the 30 mock MealData entries for the past 30 days
// If available, sleep duration from individual night data is matched and attached
Future<List<MealData>> generateMockMeals(SleepDataProvider sleepProvider) async { // the SleepDataProvider is a required input to be able to fetch the sleepData of the night and link it to the meal
  final List<MealData> mockMeals = [];
  final now = DateTime.now(); 
  
  final random = Random(); 

  // Loop through the last 30 days
  for (int i = 0; i < 30; i++) {
    final dateForMeal = now.subtract(Duration(days: i + 1)); // the last mock meal will be associated to yesterday, the first mock meal to 30 days ago
    final formattedDateForMeal = DateFormat('yyyy-MM-dd').format(dateForMeal);

    // Generate mock meals that vary everyday
    late int carbs, fats, proteins; // late ---> the value will be assigned to the variable later on, but for sure before the variable is going to be used
    late String mealTypeString;

    // Randomly pick a meal archetype for the day to simulate different eating patterns
    int mealType = random.nextInt(4); // generates a number from 0 to 3

    // The meal macronutrients intake was calculated on some base assumptions: 
    // - we hypotized a total daily intake of 2500 kcal 
    // - we considered the dinner to be about the 35% of the total daily intake ---> 875 kcal
    // - we then considered a balanced meal, based on the guidelines, to be: 55% carbs, 30% fats, 15% proteins
    // - a meal was considered high-carb if 70% of the intake was from carbs (then 15% form fats and 15% from proteins)
    // - a meal was considered high-fat if 45% of the intake was from fats (then 40% from carbs and 15% from proteins)
    // - a meal was considered high-protein if 35% of the intake was from proteins (then 45% from carbs and 20% from fats)
    // The translation from kcal to g was made based on the Atwater System: 1g of carbs = 4 kcal, 1g of proteins = 4 kcal, 1g of fats = 9kcal
    switch (mealType) { // checks the value of mealType and executes the code for the matching case
      case 0:
        // Archetype 0: Balanced Meal (Carbs ~120g, Fats ~29g, Proteins ~33g)
        mealTypeString = 'balanced';
        carbs = 110 + random.nextInt(21); // 110-130g
        fats = 25 + random.nextInt(9);    // 25-33g
        proteins = 30 + random.nextInt(7);  // 30-36g
        break;
      case 1:
        // Archetype 1: High-Carb Meal (Carbs ~153g, Fats ~15g, Proteins ~33g)
        mealTypeString = 'highCarb';
        carbs = 145 + random.nextInt(17); // 145-161g
        fats = 12 + random.nextInt(7);    // 12-18g
        proteins = 30 + random.nextInt(7);  // 30-36g
        break;
      case 2:
        // Archetype 2: High-Fat Meal (Carbs ~88g, Fats ~44g, Proteins ~33g)
        mealTypeString = 'highFat';
        carbs = 80 + random.nextInt(17); // 80-96g
        fats = 40 + random.nextInt(9);   // 40-48g
        proteins = 30 + random.nextInt(7); // 30-36g
        break;
      case 3:
        // Archetype 3: High-Protein Meal (>35% protein calories)
        // (Carbs ~96g, Fats ~19g, Proteins ~79g)
        mealTypeString = 'highProtein';
        carbs = 90 + random.nextInt(13);  // 90-102g
        fats = 16 + random.nextInt(7);    // 16-22g
        proteins = 75 + random.nextInt(9);  // 75-83g
        break;
    }

    double? sleepHoursForThisMeal; // ? because there could be no sleep data for that night (it is initialized as null and will be assigned a value after fetching the data, if there's data)

    try {
      // Fetch sleep data for the specific night corresponding to the meal date
      await sleepProvider.fetchSleepNightData(formattedDateForMeal);
      // Check if the fetched data corresponds to the requested date and has a valid duration
      // sleepProvider.sleepNightData will be null if the fetch failed or no data was returned
      if (sleepProvider.sleepNightData != null && sleepProvider.sleepNightData!.time == formattedDateForMeal) { // the check on the time is essential for when there is no sleep data for the formattedDateForMeal, since in that case it doesn't update (the saved data will be of the previous night)
        // Convert duration from minutes to hours
        if (sleepProvider.sleepNightData!.duration > 0) { // a duration of 0 is considered as "No sleep recorded" for that night
          sleepHoursForThisMeal = sleepProvider.sleepNightData!.duration / 60.0; // ! ---> data is not null now
        }
      }
    } catch (e) {
      // If there's an error fetching sleep data for a specific day print an error and leave sleepHoursForThisMeal as null
      print('Could not fetch sleep data for $formattedDateForMeal: $e');
    }

    // Create the MealData object, attaching sleep hours
    mockMeals.add(MealData(
      date: formattedDateForMeal,
      carbs: carbs,
      fats: fats,
      proteins: proteins,
      mealType: mealTypeString,
      sleepHours: sleepHoursForThisMeal, // it will be null if not found or if the fetch failed
    ));
  }
  
  mockMeals.sort((a, b) => b.date.compareTo(a.date)); // sorts data in descending order, from newest to oldest
                                                      // the list of mock meals is created in ascending order so it needs to be sorted for correct display
  
  return mockMeals;
}