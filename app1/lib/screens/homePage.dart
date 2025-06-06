import 'package:flutter/material.dart';
import 'package:app1/widgets/my_drawer.dart';
import 'package:app1/widgets/chart_switcher.dart';
import 'package:app1/widgets/user_greeting_with_avatar.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/user_profile_provider.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:app1/models/user_profile.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use addPostFrameCallback to ensure the fetch is called after the build cycle,
    // preventing issues with calling provider methods that trigger rebuilds during a build.
    // The ensureYesterdaysSleepDataFetched method has internal guards to prevent multiple fetches.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) { // Ensure the widget is still in the tree
        Provider.of<SleepDataProvider>(context, listen: false).ensureYesterdaysSleepDataFetched();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<UserProfileProvider>(
            builder: (context, userProfileProvider, _) {
              final UserProfile? currentUserProfile = userProfileProvider.userProfile();

              return Consumer<SleepDataProvider>(
                builder: (context, sleepDataProvider, _) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
                          child: UserGreetingWithAvatar(
                            currentUserProfile: currentUserProfile,
                            previousNightSleep: sleepDataProvider.yesterdaysSleepDetail,
                            isLoadingSleep: sleepDataProvider.isLoadingYesterdaysSleep,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
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