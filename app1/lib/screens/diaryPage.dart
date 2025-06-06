import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/models/meal_data.dart';
import 'package:app1/providers/meal_data_provider.dart';
import 'package:app1/providers/data_provider.dart'; 
import 'package:app1/widgets/diary_list_item.dart';
import 'package:app1/widgets/my_drawer.dart'; 
import 'package:app1/utils/mock_meals.dart'; 

class DiaryPage extends StatelessWidget {
  const DiaryPage({Key? key}) : super(key: key);

  static const routeName = '/diary'; // For navigation

  // Theme colors
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color whiteStrong = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get meal data and rebuild when it changes
    final mealDataProvider = Provider.of<MealDataProvider>(context);
    final List<MealData> meals = mealDataProvider.getSortedMeals(); // Gets sorted meals

    return Scaffold(
      extendBodyBehindAppBar: true, // To make AppBar transparent over background
      appBar: AppBar(
        title: Text(
          'Meal Diary',
          style: TextStyle(
            color: whiteStrong,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: whiteStrong), // Drawer icon color
      ),
      drawer: const MyDrawer(), // Your app's drawer
      body: Container(
        // Using the same background as HomePage for consistency
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'), // Ensure this path is correct
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.history_edu_outlined, color: darkPurple),
                  label: Text(
                    'Populate Diary (Last 30 Days)',
                    style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteStrong,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () async {
                    // Show a confirmation dialog before populating
                    bool confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Populate Diary?',  style: TextStyle(color: darkPurple)),
                            content: const Text(
                                'This will add 30 mock meal entries to your diary. Existing entries will be cleared. Continue?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel', style: TextStyle(color: darkPurple)),
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text('Confirm', style: TextStyle(color: lilla, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                },
                              ),
                            ],
                          ),
                        ) ?? false; // if dialog is dismissed, consider it false

                    if (confirm) {
                      // Get the SleepDataProvider
                      final sleepProvider = Provider.of<SleepDataProvider>(context, listen: false);
                      
                      // Show a loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Populating diary...', style: TextStyle(color: whiteStrong)), backgroundColor: lilla),
                      );

                      try {
                        final mockMeals = await generateMockMeals(sleepProvider);
                        // loadMockMealHistory will clear existing and add these
                        mealDataProvider.loadMockMealHistory(mockMeals); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Diary populated successfully!', style: TextStyle(color: whiteStrong)), backgroundColor: Colors.green),
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
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
                        itemCount: meals.length,
                        itemBuilder: (ctx, index) {
                          return DiaryListItem(meal: meals[index]);
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






/*import 'package:flutter/material.dart';
import 'package:app1/widgets/my_drawer.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true, // extend background behind app bar
      appBar: AppBar(
        title: const Text(
          'Welcome to Flutter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // transparent app bar
        elevation: 0,
        foregroundColor: Colors.white, // white text color matching profilePage
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'diaryPage',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  } // build
}
*/