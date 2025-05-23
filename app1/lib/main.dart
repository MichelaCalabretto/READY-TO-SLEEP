import 'package:app1/screens/splashPage.dart';
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
import 'package:app1/screens/homeProva.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepDataProvider(), // Fornisce il provider a tutta l'app
      child: MaterialApp(
        title: 'Trial App1',
        home: HomeProva(),  // Usa HomePage, quella con il fetch dati e provider
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

