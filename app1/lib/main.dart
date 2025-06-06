import 'package:app1/screens/splashPage.dart'; 
import 'package:app1/screens/welcomePage.dart';
import 'package:app1/screens/onboardingPage.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/screens/loginPage.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/screens/diaryPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:app1/providers/meal_data_provider.dart';
import 'package:app1/providers/user_profile_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SleepDataProvider()),
        ChangeNotifierProvider(create: (_) => MealDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Ready To Sleep',
        // theme: ThemeData(...), // You can define a global theme here

        // Set SplashPage as the initial page
        home: SplashPage(), 

        // Define named routes for navigation
        routes: {
          // You can also define a route for SplashPage if you plan to navigate to it by name later
          // SplashPage.routeName: (ctx) => SplashPage(), // Add if SplashPage has a routeName
          HomePage.routeName: (ctx) => const HomePage(),
          DiaryPage.routeName: (ctx) => const DiaryPage(),
          // Add other routes as needed:
          // OnboardingPage.routeName: (ctx) => OnboardingPage(),
          // LoginPage.routeName: (ctx) => LoginPage(),
          // ProfilePage.routeName: (ctx) => ProfilePage(),
          // GoalPage.routeName: (ctx) => GoalPage(),
        },
      ),
    );
  }
}

// Reminder: Ensure your pages have static const routeName if you want to use them in the routes map.
// Example for SplashPage (if not already done):
// In lib/screens/splashPage.dart:
// class SplashPage extends StatelessWidget {
//   static const routeName = '/splash'; // Example route name
//   const SplashPage({Key? key}) : super(key: key);
//   // ... rest of your SplashPage code
// }

// Example for HomePage (if not already done):
// In lib/screens/homePage.dart:
// class HomePage extends StatelessWidget {
//   static const routeName = '/home'; // Example route name
//   const HomePage({Key? key}) : super(key: key);
//   // ... rest of your HomePage code
// }





/*import 'package:app1/screens/splashPage.dart';
import 'package:app1/screens/welcomePage.dart';
import 'package:app1/screens/onboardingPage.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/screens/loginPage.dart';
import 'package:app1/screens/goalPage.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/screens/diaryPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:app1/widgets/my_drawer.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepDataProvider(), // Provide the SleepDataProvider to the tree below
      child: MaterialApp(
        title: 'Trial App1',
        //home: OnboardingPage()
        home: HomePage(),
        //home: SplashPage(),
        //home: LoginPage(),
        //home: GoalPage()
        //home: ProfilePage(),
        //home: DiaryPage(),
      ),
    );
  }
}*/

