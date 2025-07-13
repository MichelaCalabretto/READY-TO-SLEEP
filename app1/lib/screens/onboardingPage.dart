import 'package:flutter/material.dart';
import 'package:app1/screens/mainScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/widgets/avatar_dropdown.dart';
import 'package:app1/models/user_profile.dart';

// The onboardingPage was made Stateful to manage the inputs from the forms and the selected choice in the dropdowns; this way, when the UI rebuilds, the info saved persists and isn't rebuilt (it's also needed for updating the state)
class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingPage> {
 
  final _formKey = GlobalKey<FormState>(); // key to manage form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedGender;
  String? _selectedJob;
  String? _selectedAvatar;

  final Color darkPurple = Color.fromARGB(255, 38, 9, 68); 

  // Function that shows a calendar popup (date picker) and allows the user to pick a date of birth
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker( // showDatePicker shows the calendar
      context: context,
      initialDate: DateTime(2000), // date shown as default when you open the calendar
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { // tells Flutter to rebuild the UI with the new value ---> to show that the date was picked
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked); // the selected date is converted into a string and saved into _dateController
      });
    }
  }

  // Method to save the form (called when the user presses the Save button)
  Future<void> _submitForm() async {
    // Saves every field that was filled out; at least one field must be filled out
    bool hasAnyInput =  // true only if at least one field was filled out
      _nameController.text.trim().isNotEmpty || // .trim()  removes all leading and trailing whitespace from a string
      _surnameController.text.trim().isNotEmpty ||
      _nicknameController.text.trim().isNotEmpty ||
      _selectedGender != null ||
      _selectedJob != null ||
      _selectedAvatar != null ||
      _dateController.text.trim().isNotEmpty;
        
    if (!hasAnyInput) { // if no field was compiled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 192, 153, 227),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(8),
          duration: Duration(seconds: 2),
          content: Text('No info was provided! At least one field must be filled out, otherwise press Skip',),
        ),
      );
      return;
    }

    // Create a new instance of the UserProfile class, with all the info filled out by the user    
    final profile = UserProfile(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      gender: _selectedGender,
      dob: _dateController.text.trim(),
      job: _selectedJob,
      avatar: _selectedAvatar,
    );

    await profile.save(); // uses the save() method defined in the user_profile to save the user profile

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.fromARGB(255, 192, 153, 227),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        duration: Duration(seconds: 2),
        content: Text('Data saved')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  // Function that sets the onboarding_completed bool as true ---> the onboarding is shown only once after restarting the app
  Future<void> _setOnboardingCompleted() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_completed', true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // Stack allows to place multiple widgets one on top of the other 
        children: [
          Positioned.fill( // stretches the image to fill the entire space
            child: Image.asset(
              'assets/images/welcomePage_wallpaper.png',
              fit: BoxFit.cover, // ensures the image fills the area without distortion
            ),
          ),
          // LayoutBuilder to ensure image covers full height, including when content is larger than screen; it provides the current size constraints of its parent
          LayoutBuilder( // allows you to build child widgets based on the size of the parent widget 
            builder: (context, constraints) {
              return SingleChildScrollView( // makes the content scrollable; it sizes itself based on its content, not the size of the screen ---> that's why we added LayoutBuilder() (otherwise the wallpaper wouldn't cover the entire screen)
                child: ConstrainedBox( // applies additional constraints to its child ---> to force minimum height: this way the ScrollView's height is gonna be the entire screen
                  constraints: BoxConstraints(minHeight: constraints.maxHeight), // it's saying: even if your content is short, stretch to at least the full height of the screen
                  child: IntrinsicHeight( // sizes its child to the intrinsic height needed to fit the content
                    child: SafeArea( // ensures content isn’t hidden behind system UI elements
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Title
                            const Center(
                              child: Text(
                                'Let\'s know you better',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [

                                  // Name 
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder( // border of active form
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      labelText: 'Name',
                                      hintText: 'Enter your name',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintStyle: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Surname
                                  TextFormField(
                                    controller: _surnameController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      labelText: 'Surname',
                                      hintText: 'Enter your surname',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintStyle: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Nickname
                                  TextFormField(
                                    controller: _nicknameController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      labelText: 'Nickname',
                                      hintText: 'Choose your nickname',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintStyle: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Sex
                                  DropdownButtonFormField<String>(
                                    dropdownColor: darkPurple, // background color of the dropdown menu
                                    decoration: InputDecoration(
                                      labelText: 'Sex',
                                      labelStyle: TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    value: _selectedGender, // sets the current selected value of the dropdown ---> _selectedGender holds the value that is currently selected and shown in the dropdown
                                    items: ['M', 'F', 'Other'].map((gender) { // dropdown menu items ---> maps through the list and creates a dropdown menu item widget for each element
                                      return DropdownMenuItem<String>( // item of the dropdown menu
                                        value: gender,
                                        child: Text(gender, style: TextStyle(color: Colors.white)),
                                      );
                                    }).toList(), // converts the iterable to a List, which is what the dropdown expects
                                    onChanged: (value) => setState(() => _selectedGender = value), // updates the saved gender value when the user changes the selected menu item
                                  ),
                                  const SizedBox(height: 20),

                                  // Date of Birth
                                  TextFormField(
                                    controller: _dateController,
                                    readOnly: true, // makes the text field non-editable by keyboard input ---> users can't directly type the dob, they must choose it through the calendar
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Date of birth',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintStyle: TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    onTap: () => _selectDate(context), // when the field is tapped, it calls the _selectDate method that shows the calendar
                                  ),
                                  const SizedBox(height: 20),

                                  // Job
                                  DropdownButtonFormField<String>(
                                    dropdownColor: darkPurple,
                                    decoration: InputDecoration(
                                      labelText: 'Job',
                                      labelStyle: TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    value: _selectedJob,
                                    items: ['Student', 'Unemployed', 'Freelancer', 'Engineer', 'Doctor', 'Teacher', 'Lawyer', 'Marketing Specialist', 'Consultant', 'Architect', 'Mechanic', 'Electrician', 'Plumber', 'Artist', 'Police Officer', 'Firefighter', 'Chef', 'Retail Worker', 'Other'].map((job) {
                                      return DropdownMenuItem<String>(
                                        value: job,
                                        child: Text(job, style: TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() => _selectedJob = value), // updates the state with the new selected job
                                  ),
                                  const SizedBox(height: 20),

                                  // Avatar (uses the widget defined in the avatar_dropdown file)
                                  AvatarDropdown(
                                    selectedAvatar: _selectedAvatar,
                                    onChanged: (value) => setState(() => _selectedAvatar = value),
                                  ),
                                  const SizedBox(height: 20),

                                  // Skip and Save buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // pushes the two buttons to the sides
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await _setOnboardingCompleted(); // if the user presses skip, first we need to update the onboarding_completed flag
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => MainScreen()),
                                          );
                                        },
                                        child: Text(
                                          'Skip',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: darkPurple,
                                        ),
                                        onPressed: _submitForm,
                                        child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
