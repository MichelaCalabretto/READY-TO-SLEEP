import 'package:flutter/material.dart';
import 'package:app1/screens/goalPage.dart';
import 'package:app1/screens/onboardingPage.dart';
import 'package:app1/utils/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/screens/homePage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Impact impact = Impact();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; //MediaQuery.of(context) retrieves the dimension of the current screen
                                                             //.size retrieves a Size object withe the size of the screen
                                                             //.height retrieves the height 
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          //Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcomePage_wallpaper.png',
              fit: BoxFit.cover, //scales the image to completely cover the target box
            ),
          ),
          //Foreground content
          SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    //Logo image
                    Image.asset(
                      'assets/images/logo.png',
                      height: screenHeight * 0.20,
                    ),
                    const SizedBox(height: 20),
                    //Welcome texts
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Enter your credentials to login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    //Username field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: userController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          border: InputBorder.none,
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.symmetric(vertical: 20), //controls the spacing inside the text field where the text appears; adds 20 pixels of vertical padding (top and bottom), and 0 horizontal padding (left and right)
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Password field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          border: InputBorder.none,
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    //Login button
                    ElevatedButton(
                      onPressed: () async {
                        final result = await impact.getAndStoreTokens(userController.text, passwordController.text);
                        if (result == 200) {
                          final sp = await SharedPreferences.getInstance();
                          await sp.setString('username', userController.text);
                          await sp.setString('password', passwordController.text);
                          final onboarding_completed = await sp.getBool('onboarding_completed');
                          if (onboarding_completed == null || onboarding_completed == false) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => OnboardingPage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              backgroundColor: Color.fromARGB(255, 192, 153, 227),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(8),
                              duration: Duration(seconds: 2),
                              content: Text("Username or password incorrect"),
                            ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 182, 131, 227),
                        shape: StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    //Terms and conditions
                    Text(
                      "By logging in, you agree to Ready to Sleep's\nTerms & Conditions and Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}