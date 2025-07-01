import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app1/models/meal_data.dart'; 

class DiaryListItem extends StatelessWidget {
  final MealData meal;

  // Theme colors (consistent with Graph1/Graph2 and ChartSwitcher)
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color lightLilla = const Color.fromARGB(255, 243, 209, 255);
  final Color whiteStrong = Colors.white;
  final Color whiteShade = Colors.white70;

  const DiaryListItem({Key? key, required this.meal}) : super(key: key);

  // Helper to format date for display (e.g., "June 3, 2025")
  String _formatDisplayDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr; // Fallback to original string if parsing fails
    }
  }

  // Helper method to format sleep duration into "X hours Y minutes"
  String _formatSleepDuration(double totalHours) {
    // Ensure totalHours is positive, though MealData should ideally not store negative sleep.
    // generateMockMeals sets sleepHours to null if duration was 0, so this will be called for positive values.
    if (totalHours < 0) totalHours = 0;

    final int hours = totalHours.floor(); // Get the whole number of hours
    final int minutes = ((totalHours - hours) * 60).round(); // Convert the fractional part to minutes and round

    return '${hours} h ${minutes} min';
  }


  // A helper function to convert the raw mealType string into a display-friendly name
  String _getDisplayMealTypeName(String rawType) {
    switch (rawType) {
      case 'balanced':
        return 'Balanced Meal';
      case 'highCarb':
        return 'High-Carb Meal';
      case 'highFat':
        return 'High-Fat Meal';
      case 'highProtein':
        return 'High-Protein Meal';
      default:
        return 'Unknown';
    }
  }

  // This widget now gets the display name from the helper function
  Widget _buildMealTypeTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: lightLilla.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        _getDisplayMealTypeName(meal.mealType), // use the helper function 
        style: TextStyle(
          color: darkPurple,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The Card is the main container for each diary entry, giving it a
    // defined shape, elevation, and a semi-transparent background.
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        // Padding provides spacing between the card's border and its content
        padding: const EdgeInsets.all(16.0),
        // A Column arranges the content vertically
        child: Column(
          // Aligns content to the start (left) of the column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The first Row holds the date and the meal type tag
            Row(
              // This pushes the date to the left and the tag to the right
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Displays the formatted date of the meal
                Text(
                  _formatDisplayDate(meal.date),
                  style: TextStyle(
                    color: whiteStrong,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // This calls the helper widget to build and display the meal type tag
                _buildMealTypeTag(context),
              ],
            ),
            // A SizedBox adds vertical spacing
            const SizedBox(height: 12),
            // Each of these calls a helper method to create a consistent row for each macronutrient
            _buildMacroRow('Carbs:', '${meal.carbs} g', Icons.bakery_dining_outlined),
            _buildMacroRow('Fats:', '${meal.fats} g', Icons.oil_barrel_outlined),
            _buildMacroRow('Proteins:', '${meal.proteins} g', Icons.set_meal_outlined),
            const SizedBox(height: 10),
            // A visual separator for different sections of the card.
            Divider(color: whiteShade.withOpacity(0.5)),
            const SizedBox(height: 10),
            // The final Row displays the sleep data associated with the meal
            Row(
              children: [
                Icon(Icons.king_bed_outlined, color: lilla, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sleep: ',
                  style: TextStyle(
                      color: lilla, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    // Checks if sleep data is available and formats it, otherwise shows 'Not recorded'
                    meal.isSleepDataAvailable()
                        ? _formatSleepDuration(meal.sleepHours!)
                        : 'Not recorded',
                    style: TextStyle(color: whiteStrong, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: whiteShade, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: whiteShade, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: whiteStrong, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}