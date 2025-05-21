import 'package:flutter/material.dart';

class AvatarDropdown extends StatelessWidget {
  final String? selectedAvatar;
  final Function(String?) onChanged;

  AvatarDropdown({required this.selectedAvatar, required this.onChanged});

  final List<String> avatars = [
    'owl.png',
    'dog.png',
    'cat.png',
    'tiger.png',
    'fox.png',
    'pinguin.png',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedAvatar,
      decoration: InputDecoration(
        labelText: 'Avatar',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: avatars.map((filename) {
        return DropdownMenuItem<String>(
          value: filename,
          child: Row(
            children: [
              Image.asset(
                'images/avatars/$filename',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(filename.split('.').first.capitalize()),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      //validator: (value) =>
          //value == null ? 'Please select an avatar' : null,
    );
  }
}

extension StringCasing on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}