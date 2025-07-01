import 'package:flutter/material.dart';
import 'package:app1/screens/homePage.dart';
import 'package:app1/screens/diaryPage.dart';
import 'package:app1/widgets/custom_nav_bar.dart';

/// This is the main "shell" screen that hosts the navigation.
/// It combines the custom UI from `CustomNavBar` with the state-preserving
/// logic of `IndexedStack`, providing the best of both worlds.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // This state variable tracks the active page.
  int _selectedIndex = 0;

  // This list holds the actual page widgets that will be displayed.
  // They are kept in this list permanently while MainScreen is active.
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    DiaryPage(),
  ];

  // The callback function passed to the CustomNavBar. It updates the state.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is crucial for the floating bar effect. It allows the body
      // to extend and be visible behind the navigation bar's padding area.
      extendBody: true,

      // This is the most important part for state preservation.
      // An IndexedStack keeps ALL its children loaded in the widget tree.
      // It simply shows the one at the specified `index` and hides the others.
      // Because the other children are not discarded, their internal state (like
      // scroll position or selected dates) is perfectly preserved.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      // Here, we use our beautiful, custom-built navigation bar.
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}