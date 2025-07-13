import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app1/screens/loginPage.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/providers/user_profile_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);

  // Helper to determine the greeting text
  String _getGreeting(UserProfile? profile) {
    if (profile?.nickname?.isNotEmpty == true) { // "?." = if profile is not null access it
      return 'Hi, ${profile!.nickname!}!';
    } else if (profile?.name?.isNotEmpty == true) {
      return 'Hi, ${profile!.name!}!';
    } else {
      return 'Hi, User!';
    }
  }

  // Helper to determine the avatar path 
  String _getAvatarPath(UserProfile? profile) {
    String avatarName = profile?.avatar?.isNotEmpty == true ? profile!.avatar! : 'cat'; // if the user chose an avatar, then that is what will be shown, otherwise the default avatar is the cat (uses a ternary operator ---> condition ? expression1 : expression2)
                                                                                        // ?. is the null aware access
                                                                                        // ! to assure Dart that in this moment it is not null
   return 'assets/images/avatars/$avatarName.png';
  }


  // Private method to logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Private method that shows a confirmation dialog to the user before logging out
  void _confirmLogout(BuildContext context) {
    showDialog( // flutter function that displays a dialog window
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog( // material design dialog with a title, content, and actions
          backgroundColor: Colors.white,
          title: Text('Confirm Logout', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to log out?', style: TextStyle(color: darkPurple,)),
          actions: <Widget>[ // list of widgets that appear at the bottom of the dialog as buttons
            TextButton(
              child: Text('Cancel', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold,)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold,)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context); // gets an instancxe of the user_profile_provider
    final UserProfile? currentUserProfile = userProfileProvider.userProfile(); // gets the current userProfile

    String avatarPath = _getAvatarPath(currentUserProfile);
    String greeting = _getGreeting(currentUserProfile);

    return Drawer(
      child: Container(
        decoration: const BoxDecoration( // to set the background color
          gradient: LinearGradient(
            begin: Alignment.topLeft, // the gradient starts at the top left corner of the container
            end: Alignment.bottomRight, // the gradient stops at the bottom right corner of the container
            colors: [
              Color.fromARGB(255, 154, 134, 168), // color at the top
              Color.fromARGB(255, 181, 164, 200), // color in the middle
              Color.fromARGB(255, 213, 203, 238), // color at the bottom
            ],
          ),
        ),
        child: Column(
          children: [

            // Header whith avatar image and text
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              width: double.infinity, // the container expands to take all aviable horizontal space
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 80,  // 2 * radius = diameter
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // background color of the oval
                    ),
                    child: ClipOval(
                      child: OverflowBox( // to let the image be bigger thant the oval
                        maxWidth: 120, // the image is bigger than the circle
                        maxHeight: 120,
                        child: Image.asset(
                          avatarPath,
                          fit: BoxFit.cover, // the image will scale to cover the entire space of the container
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Divider( // visual divider horizontal line used to separate the header from the navigation through the drawer
                height: 50, // vertical space that the divider takes up
                color: Colors.white,
                thickness: 2,
              ),
            ),
            
            //Menu options
            Expanded( // makes this part take all the remaining vertical space
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  padding: EdgeInsets.zero, // removes the default padding from the list
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Logout at the bottom
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: ListTile(
                leading: Icon(Icons.logout, color: darkPurple),
                title: Text('LogOut', style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold, fontSize: 20,)),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}