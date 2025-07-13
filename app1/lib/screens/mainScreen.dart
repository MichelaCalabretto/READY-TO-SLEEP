import 'package:flutter/material.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/screens/diaryPage.dart';
import 'package:app1/widgets/custom_nav_bar.dart';
import 'package:app1/widgets/my_drawer.dart';

// This is the mainScreen that hosts the navigation bar, the drawer, the homePage and the diaryPage
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // variable that tracks the currently selected page

  // Variables to detect when the drawer is open ---> to hide the navigation bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // key to control and access the state of the Scaffold, like opening/closing the drawer when needed
  bool _isDrawerOpen = false;

  // List that holds the actual page widgets that will be displayed (the homePage and the diaryPage)
  // These widgets stay alive as long as the MainScreen is active (this way there's no reloading between switches)
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    DiaryPage(),
  ];

  // Callback function passed to the CustomNavBar that updates the state ---> it triggers the rebuild to switch the visible page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // updates the index of the currently selected page
    });
  }

  // Function that tracks whether the drawer is open or closed and updates the local state variable
  void _handleDrawerChanged(bool isOpened) {
    setState(() {
      _isDrawerOpen = isOpened;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // assigns the previously defined key to the current Scaffold
      extendBody: true, // allows the body to be visible behind the navigation bar
      drawer: const MyDrawer(), // the drawer is now handled in the mainScreen, to allow hiding the navigation bar when it is open
      onDrawerChanged: _handleDrawerChanged, // detects open/closeed drawer

      // The IndexedStack keeps ALL its children loaded in the widget tree and simply shows the one at the specified index and hides the others
      // Because the other children are not discarded, their internal state (like the scroll position or the selected dates) is preserved
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      // Navigation bar, shown conditionally on wheter the drawer is open or not
      bottomNavigationBar: _isDrawerOpen
            ? null
            : CustomNavBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped, // defines how the callback function onTap "initialized" in custom_nav_bar.dart behaves ---> uses the function defined in this file, _onItemTapped, that updates the state 
              ),
    );
  }
}