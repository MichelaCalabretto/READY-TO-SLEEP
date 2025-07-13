import 'package:flutter/material.dart';
import 'package:app1/screens/loginPage.dart';

class WelcomePage extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true, // allows content behind status/navigation bar
      body: SafeArea(  // SafeArea ensures that content avoids system UI ---> full screen design
        top: false,
        bottom: false,
        child: Container(
          width: double.infinity, // the container will fill the entire screen
          height: double.infinity,
          child: Stack( // Stack allows to place multiple widgets one on top of the other 
            children: [
              // Wallpaper
              Positioned.fill( // stretches the image to fill the entire space
                child: Image.asset(
                  'assets/images/welcomePage_wallpaper.png',
                  fit: BoxFit.cover, // ensures the image fills the area without distortion
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // centers vertically
                    crossAxisAlignment: CrossAxisAlignment.stretch, // makes the children fill the horizontal space entirely
                    children: [
                      Center(

                        // App's logo
                        child: ClipOval( // for circular image
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover, // ensures the image fills the area without distortion
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Welcome text
                      Text('Welcome to\nReady to Sleep!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 30),

                      // Second text
                      Text('Sleep well, live better!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 40),

                      // Message to the user
                      Text("Eat smarter, sleep better. See how tonight's dinner can transform tomorrow's rest and unlock a new level of wellbeing.", 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        )
                      ),
                      SizedBox(height: 10),
                      Text('-The developers',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,),
                      ),
                      SizedBox(height: 30),

                      // Navigation to the loginPage
                      Center(
                        child: ElevatedButton(
                        onPressed: () {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => LoginPage())); 
                          },
                          style: ElevatedButton.styleFrom( // .styleFrom to customize the button appearance
                            backgroundColor: Colors.white, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),), 
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20), // internal padding
                          ),
                          child: Text(
                            'To LoginPage',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        )
      ),
    );
  }
}