import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app1/screens/loginPage.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/screens/diaryPage.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/providers/user_profile_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Helper to determine greeting text
  String _getGreeting(UserProfile? profile) {
    if (profile?.nickname?.isNotEmpty == true) { //"?." = if profile is not null access it
      return 'Hi, ${profile!.nickname!}';
    } else if (profile?.name?.isNotEmpty == true) {
      return 'Hi, ${profile!.name!}';
    } else {
      return 'Hi, User';
    }
  }

  // Helper to determine avatar path (consistent with HomePage)
  // For the drawer, we always want neutral verison
  String _getAvatarPath(UserProfile? profile) {
    String avatarName = profile?.avatar?.isNotEmpty == true ? profile!.avatar! : 'cat';
  
    // Fallback for any error or missing specific avatar
    //String fallbackAvatarAssetPath = 'assets/images/avatars/cat.png'; 

    // Attempt to create the primary path
    String primaryAvatarPath = 'images/avatars/${avatarName}.png';
    
    // Here we just construct the path. The Image.asset errorBuilder will handle missing assets.
    return primaryAvatarPath; // The errorBuilder in Image.asset will catch if this doesn't exist
  }


  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Logout', style: TextStyle(color: Color.fromARGB(255, 38, 9, 68), fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to log out?', style: TextStyle(color: Color.fromARGB(255, 38, 9, 68),)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 38, 9, 68), fontWeight: FontWeight.bold,)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: Color.fromARGB(255, 38, 9, 68), fontWeight: FontWeight.bold,)),
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
    final userProfileProvider = Provider.of<UserProfileProvider>(context); //to get an instancxe of the user_profile_provider
    final UserProfile? currentUserProfile = userProfileProvider.userProfile(); //gets the current userProfile
    //final bool isLoadingProfile = userProfileProvider.isLoading();

    String avatarPath = _getAvatarPath(currentUserProfile);
    String greeting = _getGreeting(currentUserProfile);
    // Fallback avatar if the dynamic one fails to load
    String fallbackDrawerAvatar = 'images/avatars/cat.png'; 

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 154, 134, 168), // color at the top
              Color.fromARGB(255, 181, 164, 200), // color in the middle
              Color.fromARGB(255, 213, 203, 238), // color at the bottom
            ],
          ),
        ),
        child: Column(
          children: [
            // Header whith image and text
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  //const CircleAvatar(
                    //backgroundImage: AssetImage('images/avatars/cat.png'),
                    //radius: 40,
                  //),
                  Container(
                    width: 80,  // 2 * radius = diametro cerchio
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // background color of the oval
                    ),
                    child: ClipOval(
                      child: OverflowBox(
                        maxWidth: 120, // the image is bigger than the circle
                        maxHeight: 120,
                        child: Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                          // Fallback if the specific avatar is not found
                          return Image.asset(fallbackDrawerAvatar, fit: BoxFit.cover, width: 120, height: 120);
                        },
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
              child: Divider(
                height: 50,
                color: Colors.white,
                thickness: 2,
              ),
            ),
            
            //Menu options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  padding: EdgeInsets.zero,
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
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.white),
                      title: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,)),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book, color: Colors.white),
                      title: const Text('Diary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,)),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DiaryPage()),
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
                leading: const Icon(Icons.logout, color: Color.fromARGB(255, 38, 9, 68)),
                title: const Text('LogOut', style: TextStyle(color: Color.fromARGB(255, 38, 9, 68), fontWeight: FontWeight.bold, fontSize: 20,)),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}