import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex; // holds the index of the currently selected tab (0 = Home, 1 = Diary)
  final Function(int) onTap; // callback function that gets triggered when a user taps on a navigation bar item; it recieves in input the index of the tapped item
                             // how this function behaves is defined in the mainScreen ---> when called it updates the state with the new current index

  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // SafeArea ensures that the navigation bar isn't obscured by system UI elements
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // padding between the navigation bar and the entire screen
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // padding inside the navigation bar (texts and icons)
          decoration: BoxDecoration( // BoxDecoration to customize the appearance of the Container widget
            color: darkPurple.withOpacity(0.65), // background color
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [ // to add shadowing 
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5), // the shadow gos down 5 pixel (X = 0, Y = 5)
              ),
            ],
          ),
          // The Row widget will contain the navigation bar items 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // spaceAround to distributes the free space evenly between and around the items
            children: [
              // Each item is created using a private helper widget _NavBarItem
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                // isSelected is true only if this item's index (Home = 0) matches the current index
                isSelected: currentIndex == 0,
                // Pass the tap handler which will call the parent's callback with index 0
                onTap: () => onTap(0),
                selectedColor: lilla,
                unselectedColor: Colors.white70,
              ),
              _NavBarItem(
                icon: Icons.menu_book_rounded,
                label: 'Diary',
                isSelected: currentIndex == 1, // (Diary = 1)
                onTap: () => onTap(1), // pass the current index
                selectedColor: lilla,
                unselectedColor: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Private helper widget for building each individual item in the navigation bar
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
});

  @override
  Widget build(BuildContext context) {
    // The color is determined conditionally based on the isSelected flag
    final color = isSelected ? selectedColor : unselectedColor;

    // InkWell is a gesture detector widget that listens for tap events and provides a ripple (splash) effect when tapped
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // The item is a Column containing an Icon and a Text label
        child: Column(
          mainAxisSize: MainAxisSize.min, // the column takes up minimum vertical space
          children: [
            Icon(icon, color: color), // how you create an Icon widget, with a specific icon and color
            const SizedBox(height: 4), // small space between the icon and label
            Text(
              label,
              style: TextStyle(
                color: color,
                // The font is bolded only when the item is selected for emphasis
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}