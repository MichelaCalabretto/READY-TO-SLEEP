import 'package:flutter/material.dart';

/// A custom-styled, floating navigation bar widget specifically for your app.
/// It is a StatelessWidget because its appearance is determined entirely by the
/// properties passed into it (`currentIndex` and `onTap` callback). It does not
/// manage any state internally, making it highly reusable and efficient.
class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // By defining the theme colors here, we ensure the widget is consistent
  // with the rest of your app's design.
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // SafeArea ensures the bar is not rendered under system intrusions like
    // the "home bar" on iOS, making it fully visible and tappable.
    return SafeArea(
      child: Padding(
        // Padding provides space around the bar, making it "float" visually.
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Container(
          // Padding inside the container gives the icons and text breathing room.
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            // The color is semi-transparent to blend with the background wallpaper.
            color: darkPurple.withOpacity(0.65),
            // A large borderRadius creates the pill or stadium shape.
            borderRadius: BorderRadius.circular(30.0),
            // The boxShadow adds depth, making the bar lift off the page.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // A Row widget arranges the navigation items horizontally.
          child: Row(
            // `spaceAround` distributes the free space evenly between and around the items.
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Each item is created using a private helper widget `_NavBarItem`.
              // This avoids duplicating layout code and makes the build method easy to read.
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                // `isSelected` is true only if this item's index (0) matches the current index.
                isSelected: currentIndex == 0,
                // Pass the tap handler which will call the parent's callback with index 0.
                onTap: () => onTap(0),
                selectedColor: lilla,
                unselectedColor: Colors.white70,
              ),
              _NavBarItem(
                icon: Icons.menu_book_rounded,
                label: 'Diary',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
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

/// A private helper widget for building each individual item in the nav bar.
/// This componentizes the UI, making it modular and easier to maintain.
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
    // The color is determined conditionally based on the `isSelected` flag.
    final color = isSelected ? selectedColor : unselectedColor;

    // InkWell provides the material splash/ripple effect when tapped.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // The item is a Column containing an Icon and a Text label.
        child: Column(
          mainAxisSize: MainAxisSize.min, // The column takes up minimum vertical space.
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4), // A small space between the icon and label.
            Text(
              label,
              style: TextStyle(
                color: color,
                // The font is bolded only when the item is selected for emphasis.
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