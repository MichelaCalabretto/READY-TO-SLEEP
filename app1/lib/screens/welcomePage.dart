import 'package:flutter/material.dart';
import 'package:app1/screens/loginPage.dart';

class WelcomePage extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Stack(
          children: [
            Positioned.fill( //wallpaper image
              child: Opacity( //to make the wallpaper image transparent 
                opacity: 0.3,
                child: Image.asset(
                'assets/images/wallpaper_welcomepage.png', 
                fit: BoxFit.cover),
              ),
            ),
            Center(
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
                  SizedBox(height: 50),
                  Text('Welcome to Ready to Sleep!', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: 40),
                  Text('Sleep well, live better!', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: 40),
                  Text('We hope that this app will help you recognize how essential sleep is,\nbecause sleeping well today means living better tomorrow.\n-the developers', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    )
                  ),
                  SizedBox(height: 40),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => LoginPage()));
                      },
                      child: Text(
                        'Login',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }
}