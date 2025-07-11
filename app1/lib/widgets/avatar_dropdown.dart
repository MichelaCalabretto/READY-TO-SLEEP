import 'package:flutter/material.dart';

class AvatarDropdown extends StatelessWidget {
  final String? selectedAvatar;
  final Function(String?) onChanged; // callback function to notify the parent widget when a new avatar is selected
                                     // the function input is a String that can be nullable ---> the funtion then returns nothing

  AvatarDropdown({required this.selectedAvatar, required this.onChanged});

  // List of available avatar image filenames
  final List<String> avatars = [
    'owl',
    'dog',
    'cat',
    'tiger',
    'fox',
    'pinguin',
  ];

  @override
  Widget build(BuildContext context) {
    final Color darkPurple = Color.fromARGB(255, 38, 9, 68); // reference color

    // DropdownButtonFormField is a form field widget that allows users to select from a dropdown list of options
    return DropdownButtonFormField<String>( 
      value: selectedAvatar, // currently selected avatar that will be shown in the form field
      dropdownColor: darkPurple, // matches the dropdown background with app theme
      decoration: InputDecoration(
        labelText: 'Avatar',
        labelStyle: TextStyle(color: Colors.white), // label text in white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), // default border (fallback) in white
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), // enabled border in white (when the field is enabled but not focused)
        ),
      ),
      // Create a list of dropdown items by looping through the avatars list
      items: avatars.map((filename) { // = for (String filename in avatars) {...}
                                      // transforms the avatars list into a map, to loop through each object (that will be called filename)
        return DropdownMenuItem<String>( // DropdownMenuItem that will be shown as an option in the dropdown
          value: filename,
          child: Row(
            children: [
              Image.asset(
                'images/avatars/$filename.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(
                filename.capitalize(), // the text in the dropdown will start with a capital letter
                style: TextStyle(color: Colors.white), 
              ),
            ],
          ),
        );
      }).toList(), // returns the Map into a List since the Map was needed just for the loop, and "items:" expects a List
      onChanged: onChanged,
    );
  }
}

// Extension method to capitalize the first letter of a string
extension StringCasing on String { // define a new extension of the String class called StringCasing 
  String capitalize() { // defin e a new ethod of the extension
    return this[0].toUpperCase() + substring(1); // .substring(1) returns the string starting from index=1 (everything apart from the first letter)
  }
}
