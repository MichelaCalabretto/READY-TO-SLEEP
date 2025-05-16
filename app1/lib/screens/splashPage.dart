import 'package:app1/screens/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin { //a Ticker object is needed to handle animation with a StatefulWidget in Flutter; it's used to handle complicated animation that require explicit time control
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    //await the end of the image animation
    await Future.delayed(const Duration(milliseconds: 1500));

    //show the loader
    setState(() => _showLoader = true);

    //await and then go to the WelcomePage
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; //check to avoid encountering errors: mounted is a bool variable of the State and is false if the widget was delated (with pop or pushReplacement)
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            //image animation
            Image.asset('assets/images/splashPage_wallpaper.png')
                .animate() //to animate the widget
                .scale( //we are animating the scale (zooming in and out)
                  duration: 1200.ms,
                  curve: Curves.easeOutBack, //defines the timingCurve: starts fast, overshoots a little (like a bounce), and then settles
                  begin: const Offset(0, 0), //starting point: image dimension is (scaleX=0,scaleY=0)
                  end: const Offset(1, 1), //ending point: (scalX=1,scaleY=1)
                ),

            //shows the loader
            if (_showLoader)
              const Positioned(
                bottom: 60, //distance from the bottom edge of the stack
                child: CircularProgressIndicator(color: Color.fromARGB(255, 109, 104, 121)),
              ),
          ],
        ),
      ),
    );
  }
}