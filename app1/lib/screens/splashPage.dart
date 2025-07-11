import 'package:app1/screens/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin { // a Ticker object is needed to handle animation with a StatefulWidget in Flutter
                                                                                 // it's used to handle complicated animation that require explicit time control
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _startSequence(); // triggers _startSequence() to start the animation and loader transition
  }

  // Method that orchestrates the animation sequence of the splash page
  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // waits 1.5 seconds to allow the image animation to play before showing the loader

    // Show the loader
    setState(() => _showLoader = true); 

    // Await and then go to the WelcomePage
    await Future.delayed(const Duration(seconds: 2)); // keeps the loader visible for another 2 seconds
    if (!mounted) return; // check to avoid encountering errors: mounted is a bool variable of the State and is false if the widget was delated (with pop or pushReplacement) ---> proceed only if the widget is still there
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack( // Stack to overlay multiple widgets (image and loader)
          alignment: Alignment.center,
          children: [
            // Image animation
            Image.asset('assets/images/splashPage_wallpaper.png')
                .animate() // to animate the widget
                .scale( // we are animating the scale (zooming in and out)
                  duration: 1200.ms,
                  curve: Curves.easeOutBack, // defines the timingCurve: starts fast, overshoots a little (like a bounce), and then settles
                  begin: const Offset(0, 0), // starting point: image dimension is (scaleX = 0, scaleY = 0)
                  end: const Offset(1, 1), // ending point: (scalX = 1, scaleY = 1)
                ),

            // Shows the loader
            if (_showLoader)
              const Positioned(
                bottom: 60, // distance from the bottom edge of the stack
                child: CircularProgressIndicator(color: Color.fromARGB(255, 109, 104, 121)),
              ),
          ],
        ),
      ),
    );
  }
}