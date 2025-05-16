import 'package:flutter/material.dart';
import 'package:app1/screens/loginPage.dart';

class WelcomePage extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true, //allows content behind status/navigation bar
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill( //wallpaper image
                child: Opacity( //to make the wallpaper image transparent 
                  opacity: 1,
                  child: Image.asset(
                  'assets/images/welcomePage_wallpaper.png', 
                  fit: BoxFit.cover),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), // padding orizzontale di 20px
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, //centers horizontally
                    crossAxisAlignment: CrossAxisAlignment.stretch, //centers vertically
                    children: [
                      Center(
                        child: ClipOval( //app's logo
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text('Welcome to\nReady to Sleep!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 30),
                      Text('Sleep well, live better!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 40),
                      Text('We hope that this app will help you recognize how essential sleep is, because sleeping well today means living better tomorrow.', 
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
                      Center(
                        child: ElevatedButton(
                        onPressed: () {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => LoginPage())); 
                          },
                          style: ElevatedButton.styleFrom( 
                            backgroundColor: Colors.white, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),), 
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                          ),
                          child: Text(
                            'Login',
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