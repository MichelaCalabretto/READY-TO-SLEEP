import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/meal_data_provider.dart';

class MealEntryDialog extends StatefulWidget {
  const MealEntryDialog({super.key});

  // Static method to easily trigger the dialog from anywhere
  static void show(BuildContext context) { //method to show the dialog without needing to create an instance beforehead (thanks to static)
    showDialog( //built-in function in flutter to show the dialog window
      context: context, // context to know which part of the application's widget tree it should display the dialog on top of
      builder: (ctx) => const MealEntryDialog(),
    );
  }

  @override
  State<MealEntryDialog> createState() => _MealEntryDialogState();
}

class _MealEntryDialogState extends State<MealEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _proteinsController = TextEditingController();

  // Theme colors 
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color snackbarColor = const Color.fromARGB(255, 255, 137, 255);


  @override
  void dispose() {
    _carbsController.dispose();
    _fatsController.dispose();
    _proteinsController.dispose();
    super.dispose();
  }

  /// Handles the main logic when "Save" is pressed on the input dialog
  Future<void> _handleMealAnalysisAndConfirmation() async {
    if (!_formKey.currentState!.validate()) { //"_formKey" to access the form; ".currentState" to access the state, in particulare the validation; ".validate()" to check if the form content is valid
      return; // Invalid input
    }

    final carbs = int.parse(_carbsController.text);
    final fats = int.parse(_fatsController.text);
    final proteins = int.parse(_proteinsController.text);

    // Access the provider to get historical meal data
    final mealProvider = context.read<MealDataProvider>();
    final allMeals = mealProvider.getSortedMeals();

    // ANALYSIS
    String feedbackMessage;
    final similarMealsWithSleep = allMeals.where((meal) {
      // Find similar meals from the last 30 days that have sleep data
      return meal.isSleepDataAvailable() && _isMealSimilar(meal, carbs, fats, proteins);
    }).toList();

    if (similarMealsWithSleep.isEmpty) {
      feedbackMessage = "Your meal has been recorded. Let's see how you sleep tonight!";
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

    // Close the current input dialog
    Navigator.of(context).pop();

    // Show the confirmation dialog with the feedback message
    final bool? confirmed = await showDialog<bool>( //function that displays the dialog
      context: context,
      barrierDismissible: false, // User must choose an action: forces the user to interact with the dialog
      builder: (ctx) => AlertDialog( //widget being returned ---> text sshown in the dialog window
        backgroundColor: Colors.white,
        title: Text('Sleep Prediction', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
        content: Text(feedbackMessage, style: TextStyle(color: darkPurple)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: darkPurple)),
            onPressed: () => Navigator.of(ctx).pop(false), // Returns false
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: lilla),
            child: const Text('Confirm Meal', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true), // Returns true
          ),
        ],
      ),
    );

    // Save the data if confirmed, otherwise re-show the input dialog
    if (confirmed == true) {
      _saveMeal(mealProvider, carbs, fats, proteins);
    } else {
      // If user cancels, show the initial dialog again with the entered values
      MealEntryDialog.show(context);
    }
  }

  /// Helper function to define what a "similar" meal is
  /// Here, we check if each macronutrient is within a +/- 25% range
  bool _isMealSimilar(MealData oldMeal, int newCarbs, int newFats, int newProteins) {
    final carbRange = oldMeal.carbs * 0.25;
    final fatRange = oldMeal.fats * 0.25;
    final proteinRange = oldMeal.proteins * 0.25;

    final carbMatch = (newCarbs >= oldMeal.carbs - carbRange) && (newCarbs <= oldMeal.carbs + carbRange);
    final fatMatch = (newFats >= oldMeal.fats - fatRange) && (newFats <= oldMeal.fats + fatRange);
    final proteinMatch = (newProteins >= oldMeal.proteins - proteinRange) && (newProteins <= oldMeal.proteins + proteinRange);

    return carbMatch && fatMatch && proteinMatch;
  }

  /// Saves the meal using the provider
  void _saveMeal(MealDataProvider provider, int carbs, int fats, int proteins) {
    provider.addOrUpdateMeal(carbs: carbs, fats: fats, proteins: proteins); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Tonight's meal has been saved to your diary!"),
        backgroundColor: snackbarColor,
      ),
    );
  }

  /// Builds the initial dialog for macronutrient input
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Record Tonight's Dinner", style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkPurple),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: darkPurple)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: lilla, width: 2)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], //allows only digits
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }
}