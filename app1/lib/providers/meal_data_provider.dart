import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app1/models/meal_data.dart';


class MealDataProvider extends ChangeNotifier {
  // Internal private list to store meals (acts as in-memory database)
  final List<MealData> _meals = []; 

  // Returns a sorted and unmodifiable copy of meals (from most recent to oldest)
  List<MealData> getSortedMeals() {
    final copy = List<MealData>.from(_meals); // make a modifiable copy of the internal list
    copy.sort((a, b) => b.date.compareTo(a.date)); // sort by date descending
    return List.unmodifiable(copy); // prevent external modification
  }

  // Adds or updates a meal for today (only allowed before midnight)
  void addOrUpdateMeal({
    required int carbs,
    required int fats,
    required int proteins,
    required String mealType,
  }) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final existingIndex = _meals.indexWhere((meal) => meal.date == today); // .indexWhere is a List's method that allows to search inside a List where a certain condition is verified
                                                                           // in this case the condition to be verified is if a meal for the specific date already exists
                                                                           // if not, it returns -1, if it exists, it returns the index of the meal in the list

    if (existingIndex != -1) {
      // If meal for today already exists, update it
      _meals[existingIndex].carbs = carbs;
      _meals[existingIndex].fats = fats;
      _meals[existingIndex].proteins = proteins;
      _meals[existingIndex].mealType = mealType;
    } else {
      // Else, create and add new meal
      _meals.add(MealData(
        date: today,
        carbs: carbs,
        fats: fats,
        proteins: proteins,
        mealType: mealType,
      ));
    }

    notifyListeners(); // notify listeners to update UI
  }

  // Returns the meal for a given date, if any
  MealData? getMealForDate(String date) {
    try {
      return _meals.firstWhere((meal) => meal.date == date);
    } catch (e) {
      return null; // no matching meal found
    }
  }

  // Assigns sleep duration to a meal after sleep data is available
  void updateSleepHours(String date, double hours) {
    final meal = getMealForDate(date);
    if (meal != null) {
      meal.sleepHours = hours;
      notifyListeners(); // notify listeners only if we made a change
    }
  }

  // Loads mock past meals into the provider
  // Used to populate 30 fake meals when the user presses the "populate diary" button
  void loadMockMealHistory(List<MealData> mockMeals) {
    //_meals.clear();
    _meals.addAll(mockMeals);
    notifyListeners(); // notify listeners to show the mock data
  }

  // Clears all meal data (used for reset/debug)
  void clearAllMeals() {
    _meals.clear();
    notifyListeners(); // notify listeners so the UI updates accordingly
  }
}
