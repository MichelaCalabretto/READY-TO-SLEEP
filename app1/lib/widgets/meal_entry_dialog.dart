import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/meal_data_provider.dart';

class MealEntryDialog extends StatefulWidget {
  const MealEntryDialog({super.key});

  // Static method to easily trigger the dialog from anywhere
  static void show(BuildContext context) { // method to show the dialog without needing to create an instance beforehead (thanks to static)
  // This method can be called like this: MealEntryDialog.show(context) ---> instead of using, every time, showDialog(context: context, builder: (_) => MealEntryDialog(),);
    showDialog( // built-in function in flutter to show the dialog window
      context: context, // context to know which part of the application's widget tree it should display the dialog on top of
      builder: (ctx) => const MealEntryDialog(),
    );
  }

  @override
  State<MealEntryDialog> createState() => _MealEntryDialogState();
}

class _MealEntryDialogState extends State<MealEntryDialog> {
  final _formKey = GlobalKey<FormState>(); // key that uniquely identifies the form widget and allows to validate or interact with the form state ---> needed for checking if all form fields pass the validation
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _proteinsController = TextEditingController();

  // Theme colors 
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color snackbarColor = const Color.fromARGB(255, 255, 137, 255);


  @override // overrides the dispose() method that exists in the _MealEntryDialogState (the superclass)
  void dispose() {
    _carbsController.dispose();
    _fatsController.dispose();
    _proteinsController.dispose();
    super.dispose(); // this calls the original dispose() method defined in the superclass 
  }

  // Handles the main logic when "Analyze & Save" is pressed in the input dialog
  Future<void> _handleMealAnalysisAndConfirmation() async { 
    // Checks if all the form fiels are valid
    if (!_formKey.currentState!.validate()) { // "_formKey" to access the form; ".currentState" to access the state, in particulare the validation; ".validate()" to check if the form content is valid
      return; // invalid input
    }

    // Here, I'm sure that all the fields were filled out
    final carbs = int.parse(_carbsController.text);
    final fats = int.parse(_fatsController.text);
    final proteins = int.parse(_proteinsController.text);

    // Access the provider to get historical meal data
    final mealProvider = context.read<MealDataProvider>(); // access the provider in "read only" mode 
    final allMeals = mealProvider.getSortedMeals(); // gets a sorted and unmodifiable list of all the meals using the method defined in the provider

    // ANALYSIS
    String feedbackMessage;
    
    final similarMealsWithSleep = allMeals.where((meal) { // cehck in the List allMeals all the meals that satisfy the condition, and adds them to the similarMealsWithSleep List
      // Find similar meals from the history that have sleep data
      return meal.isSleepDataAvailable() && _isMealSimilar(meal, carbs, fats, proteins); // .isSleepDataAviable() is defined in meal_data and checks if the meal has associated sleepData
                                                                                         // _isMealSimilar() is the private method defined later on in this file to check if the meal is similar, within a 25% range
    }).toList();

    if (similarMealsWithSleep.isEmpty) {
      feedbackMessage = "This seems to be a new type of meal for you. Let's see how you sleep tonight!";
    } else {
      // Calculate the average sleep for those similar meals
      double totalHours = 0;
      for (var meal in similarMealsWithSleep) {
        totalHours = totalHours + meal.sleepHours!;
      }
      double avgSleepHours = totalHours / similarMealsWithSleep.length;
      if (avgSleepHours < 6) {
        feedbackMessage = "Just a heads-up: when your dinner is similar to this, you've typically slept less than 6 hours. Let's see if tonight is different!";
      } else if (avgSleepHours <= 8) {
        feedbackMessage = "Looking good! Meals like this have usually resulted in a solid night's sleep. Keep up the great work.";
      } else {
        feedbackMessage = "Excellent choice! Dinners like this are usually followed by over 8 hours of restful sleep. Sweet dreams!";
      }
    }

    // Show the confirmation dialog with the feedback message ---> user must either Ccancel or Confirm
    final bool? confirmed = await showDialog<bool>( // function that displays the dialog
      context: context,
      barrierDismissible: false, // user must choose an action: forces the user to interact with the dialog and choose either Cancel or Confirm
      builder: (ctx) => AlertDialog( // widget being returned ---> text sshown in the dialog window
        backgroundColor: Colors.white,
        title: Text('Sleep Prediction', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
        content: Text(feedbackMessage, style: TextStyle(color: darkPurple)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: darkPurple)),
            onPressed: () => Navigator.of(ctx).pop(false), // returns false
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: lilla),
            child: const Text('Confirm Meal', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true), // returns true
          ),
        ],
      ),
    );

    // Save the data if confirmed, otherwise re-show the input dialog
    if (confirmed == true) {
      Navigator.of(context).pop(); 
      _saveMeal(mealProvider, carbs, fats, proteins);
    } else {
      // If user cancels, show the initial dialog again 
      MealEntryDialog.show(context);
    }
  }

  // Helper function to define what a "similar" meal is
  // Checks if each macronutrient is within a +/- 25% range
  bool _isMealSimilar(MealData oldMeal, int newCarbs, int newFats, int newProteins) {
    final carbRange = oldMeal.carbs * 0.25;
    final fatRange = oldMeal.fats * 0.25;
    final proteinRange = oldMeal.proteins * 0.25;

    final carbMatch = (newCarbs >= oldMeal.carbs - carbRange) && (newCarbs <= oldMeal.carbs + carbRange);
    final fatMatch = (newFats >= oldMeal.fats - fatRange) && (newFats <= oldMeal.fats + fatRange);
    final proteinMatch = (newProteins >= oldMeal.proteins - proteinRange) && (newProteins <= oldMeal.proteins + proteinRange);

    return carbMatch && fatMatch && proteinMatch;
  }

  // Function to classify the meal type
  String _classifyMealType(int carbs, int fats, int proteins) {
    final double totalCarbCalories = carbs * 4.0;
    final double totalFatCalories = fats * 9.0;
    final double totalProteinCalories = proteins * 4.0;
    final double totalCalories = totalCarbCalories + totalFatCalories + totalProteinCalories;

    if (totalCalories == 0) return 'unknown';

    final double carbPercentage = totalCarbCalories / totalCalories;
    final double fatPercentage = totalFatCalories / totalCalories;
    final double proteinPercentage = totalProteinCalories / totalCalories;

    // These percentages were chosen arbitraly by us, since there are no guidelines on what is considered a highCarb/highFat/highProtein meal
    if (carbPercentage > 0.50) {
      return 'highCarb';
    } else if (fatPercentage > 0.45) {
      return 'highFat';
    } else if (proteinPercentage > 0.35) {
      return 'highProtein';
    } else {
      return 'balanced';
    }
  }

  // Saves the meal using the provider
  void _saveMeal(MealDataProvider provider, int carbs, int fats, int proteins) {
    final mealType = _classifyMealType(carbs, fats, proteins); // get the meal type using the private function defined earliuer
    provider.addOrUpdateMeal(carbs: carbs, fats: fats, proteins: proteins, mealType: mealType,); // use the addOrUpdateMeal method defined in the meal_data_provider to save the meal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Tonight's meal has been saved to your diary!"),
        backgroundColor: snackbarColor,
      ),
    );
  }

  // Builds the initial dialog for macronutrient input
  @override
  Widget build(BuildContext context) {
    return AlertDialog( // widget that shows a popup dialog box
      backgroundColor: Colors.white,
      title: Text("Record Tonight's Dinner", style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
      content: Form( // widget for the form
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // takes minimum space necessary
          children: [
            _buildTextField(_carbsController, 'Carbohydrates (g)'),
            const SizedBox(height: 15),
            _buildTextField(_fatsController, 'Fats (g)'),
            const SizedBox(height: 15),
            _buildTextField(_proteinsController, 'Proteins (g)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: darkPurple)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: darkPurple),
          onPressed: _handleMealAnalysisAndConfirmation,
          child: const Text('Analyze & Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) { 
    return TextFormField( // form field
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkPurple),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: darkPurple)), // default border
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: lilla, width: 2)), // border when focused
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // allows only digit inputs
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }
}