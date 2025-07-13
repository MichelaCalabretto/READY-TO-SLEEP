import 'package:flutter/material.dart';
import 'package:app1/widgets/chart_switcher.dart';
import 'package:app1/widgets/user_greeting_with_avatar.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/user_profile_provider.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:app1/models/user_profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use addPostFrameCallback to ensure the fetch is called after the build cycle, preventing issues with calling provider methods that trigger rebuilds during a build
    // The ensureYesterdaysSleepDataFetched method has internal guards to prevent multiple fetches
    WidgetsBinding.instance.addPostFrameCallback((_) { // tells Flutter to run the enclosed function after the current frame has finished building and rendering ---> wait until after the current UI build is done before executing the code
      if (context.mounted) { // ensure the widget is still in the tree
        Provider.of<SleepDataProvider>(context, listen: false).ensureYesterdaysSleepDataFetched(); // listen: false means don’t rebuild this widget when the provider change ---> "read only" mode
                                                                                                   // ensureYesterdaySleepDataFetched is the method defined in the provider to make sure yesterday’s sleep data is loaded (if no data is already loaded, it fetches it)
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ready To Sleep',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // transparent AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // color of icons in the AppBar
        // The drawer is in the mainScreen, however, a "link" is needed from the homePage to navigate the user to the drawer
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Use the context's Scaffold to open the drawer of MainScreen
            Scaffold.of(context).openDrawer(); // openDrawer() is a Flutter framework inside the ScaffoldState class
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration( // to set the background wallpaper
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'),
            fit: BoxFit.cover, // makes the image cover the entire container area
          ),
        ),
        child: SafeArea( // SafeArea prevents system UI overlays
        // Consumer that listens to the UserProfileProvider
          child: Consumer<UserProfileProvider>(
            builder: (context, userProfileProvider, _) {
              final UserProfile? currentUserProfile = userProfileProvider.userProfile(); // retrieves the current user profile data
              // Consumer that listens to the SleepDataProvider
              return Consumer<SleepDataProvider>(
                builder: (context, sleepDataProvider, _) {
                  return Column(
                    children: [

                      // Greeting with the avatar
                      Expanded(
                        flex: 2, // takes 2 parts of the available space
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
                          child: UserGreetingWithAvatar(
                            currentUserProfile: currentUserProfile,
                            previousNightSleep: sleepDataProvider.yesterdaysSleepDetail, // sleepData to be shown in the greeting
                            isLoadingSleep: sleepDataProvider.isLoadingYesterdaysSleep,
                          ),
                        ),
                      ),

                      // ChartSwitcher
                      Expanded(
                        flex: 3, // takes 3 parts of the available space
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                          child: const ChartSwitcher(),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}