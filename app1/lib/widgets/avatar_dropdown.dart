import 'package:flutter/material.dart';

class AvatarDropdown extends StatelessWidget {
  final String? selectedAvatar;
  final Function(String?) onChanged;

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
    final Color darkPurple = Color.fromARGB(255, 38, 9, 68); //reference color

    return DropdownButtonFormField<String>(
      value: selectedAvatar,
      dropdownColor: darkPurple, //matches the dropdown background with app theme
      decoration: InputDecoration(
        labelText: 'Avatar',
        labelStyle: TextStyle(color: Colors.white), //label text in white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), //border in white
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white), //enabled border in white
        ),
      ),
      items: avatars.map((filename) {
        return DropdownMenuItem<String>(
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
                filename.split('.').first.capitalize(),
                style: TextStyle(color: Colors.white), //item text in white
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      // validator: (value) =>
      //   value == null ? 'Please select an avatar' : null,
    );
  }
}

// Extension method to capitalize the first letter of a string
extension StringCasing on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
