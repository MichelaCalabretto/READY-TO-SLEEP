import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:app1/providers/meal_data_provider.dart';
import 'package:app1/providers/user_profile_provider.dart';
import 'package:app1/screens/splashPage.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // inject the provider at the top of the application tree
      providers: [
        ChangeNotifierProvider(create: (_) => SleepDataProvider()), // create an instance of the SleepDataProvider
        ChangeNotifierProvider(create: (_) => MealDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Ready To Sleep',
        home: SplashPage(), // SplashPage is the initial page, from there the navigation will automatically lead to the HomePage
      ),
    );
  }
}


