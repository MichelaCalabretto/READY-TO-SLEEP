import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/meal_data_provider.dart'; 
import 'package:app1/widgets/diary_list_item.dart'; 
import 'package:app1/utils/mock_meals.dart'; 

class DiaryPage extends StatelessWidget {
  const DiaryPage({Key? key}) : super(key: key);

  // Theme colors
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color whiteStrong = Colors.white;
  final Color snackbarColor = const Color.fromARGB(255, 255, 137, 255);

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get meal data and rebuild when it changes
    final mealDataProvider = Provider.of<MealDataProvider>(context);
    final List<MealData> meals = mealDataProvider.getSortedMeals(); // gets sorted meals

    return Scaffold(
      extendBodyBehindAppBar: true, // to extend the background beyond the AppBar
      appBar: AppBar(
        title: Text(
          'Meal Diary',
          style: TextStyle(
            color: whiteStrong,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // transparent AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: whiteStrong), // drawer icon color
        // The drawer is in the mainScreen, however, a "link" is needed from the diaryPage to navigate the user to the drawer
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Use the context's Scaffold to open the drawer of MainScreen
            Scaffold.of(context).openDrawer(); // openDrawer() is a Flutter framework inside the ScaffoldState class
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration( // to set the background wallpaper
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'), 
            fit: BoxFit.cover, // makes the image cover the entire container area
          ),
        ),
        child: SafeArea( // SafeArea prevents system UI overlays
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),

                // Populate diary button
                child: ElevatedButton.icon(
                  icon: Icon(Icons.history_edu_outlined, color: darkPurple),
                  label: Text(
                    'Populate Diary (Last 30 Days)',
                    style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteStrong,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // internal padding
                  ),
                  onPressed: () async {
                    // Show a confirmation dialog before populating
                    bool confirm = await showDialog( // to show the dialog window
                          context: context,
                          builder: (ctx) => AlertDialog( // widget to show a modal dialog with title, text, ecc...
                            title: Text('Populate Diary?',  style: TextStyle(color: darkPurple)),
                            content: const Text(
                                'This will add 30 mock meal entries to your diary. Do you want to continue?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel', style: TextStyle(color: darkPurple)),
                                onPressed: () {
                                  Navigator.of(ctx).pop(false); // returns false
                                },
                              ),
                              TextButton(
                                child: Text('Confirm', style: TextStyle(color: lilla, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.of(ctx).pop(true); // returns true
                                },
                              ),
                            ],
                          ),
                        ) ?? false; // if dialog is dismissed (the user taps outside of the dialog window and therefore closes the dialog without selecting either Cancel or Confirm), consider it false
                    if (confirm) {
                      // Show a snackBar to notify the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Populating diary...', style: TextStyle(color: whiteStrong)), backgroundColor: lilla),
                      );
                      try {
                        final mockMeals = await generateMockMeals(); // generate the mock meals using the function defined in mock_meals
                        mealDataProvider.loadMockMealHistory(mockMeals);  // load the generated mock meals in the provider
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Diary populated successfully!', style: TextStyle(color: whiteStrong)), backgroundColor: snackbarColor),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error populating diary: $e', style: TextStyle(color: whiteStrong)), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),

              // Diary items
              Expanded(
                child: meals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Your meal diary is empty.\nAdd a meal from the Home Page or populate with mock data using the button above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder( // ListView.builder() creates a scrollable list of widgets
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
                        itemCount: meals.length, // how many items must be built
                        itemBuilder: (ctx, index) { // function that builds each item in the list
                          return DiaryListItem(meal: meals[index]); // returns a DiaryListItem object correspondent to the meal
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





