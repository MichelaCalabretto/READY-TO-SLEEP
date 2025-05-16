import 'package:app1/screens/splashPage.dart';
import 'package:app1/screens/welcomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trial App1',
      home: SplashPage(),
      );
  }
}

