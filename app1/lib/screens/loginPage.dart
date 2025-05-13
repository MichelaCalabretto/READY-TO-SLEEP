import 'package:flutter/material.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/screens/onboardingPage.dart';
import 'package:app1/utils/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  // text controllers to check the username and password inserted by the user
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Impact impact = Impact();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea widget to avoid system UI overlaps
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 50, bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // import the logo image from assets folder (make sure to add the folder in pubspec.yaml)
            Image.asset(
              'assets/images/logo.png',
              scale: 4,
              ),
            const SizedBox(
                  height: 30,
                ),
            const Text(
              'Welcome',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Login',
            ),
            const SizedBox(
              height: 25,
            ),
            // TextField widgets to take the username and password from the user
            TextField(
              controller: userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Username',
                hintText: 'Enter your username',
              ),),

              const SizedBox(
                height: 20,
              ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Password',
                hintText: 'Enter your password',
              ),),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // check if credentials are correct
                    final result = await impact.getAndStoreTokens(userController.text, passwordController.text);
                    // If correct, store the username and password in SharedPreferences
                    // and navigate to the Exposure screen (pushReplacement to remove the login screen from the stack)
                    if (result == 200) {
                      final sp = await SharedPreferences.getInstance();
                      await sp.setString('username', userController.text);
                      await sp.setString('password', passwordController.text);
                      final onboarding_completed = await sp.getBool('onboarding_completed');
                      if(onboarding_completed == null || onboarding_completed == false){//null: never logged in, false:logout
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Onboarding(),
                        ),
                      );
                      }
                      else{
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      }
                      } else {
                        // If incorrect, show a SnackBar with an error message
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(8),
                              duration: Duration(seconds: 2),
                              content:
                                  Text("username or password incorrect")));
                      }
                  },
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 12)),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFF384242))),
                  child: const Text('Log In'),
                ),
              ),
            ),
            const Spacer(),
            const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "By logging in, you agree to Ready to Sleep's\nTerms & Conditions and Privacy Policy",
                  style: TextStyle(fontSize: 12),
                )),
                ]),
              ),
            
          ),
    );
  }
}