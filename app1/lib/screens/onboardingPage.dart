import 'package:flutter/material.dart';
import 'package:app1/screens/homePage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/widgets/avatar_dropdown.dart';
import 'package:app1/models/user_profile.dart';


class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingPage> {
 
  final _formKey = GlobalKey<FormState>(); //to manage form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedGender;
  String? _selectedJob;
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final profile = await UserProfile.load();
    setState(() {
      _nameController.text = profile.name ?? '';
      _surnameController.text = profile.surname ?? '';
      _nicknameController.text = profile.nickname ?? '';
      _dateController.text = profile.dob ?? '';
      _selectedGender = profile.gender;
      _selectedJob = profile.job;
      _selectedAvatar = profile.avatar;
    });
  }


  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker( //showDatePicker shows the calendar
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { //tells Flutter to rebuild the UI with the new value
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked); //selected date is converted into a string and saved into _dateController
      });
    }
  }

  Future<void> _submitForm() async {

    //Saves every field that was filled out; at least one field must be filled out
    bool hasAnyInput =  //true only if atleast one field was filled out
      _nameController.text.trim().isNotEmpty ||
      _surnameController.text.trim().isNotEmpty ||
      _nicknameController.text.trim().isNotEmpty ||
      _selectedGender != null ||
      _selectedJob != null ||
      _selectedAvatar != null ||
      _dateController.text.trim().isNotEmpty;
        
    if (!hasAnyInput) { //if no field was compiled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No info was provided! At least one field must be filled out, otherwise press Skip')),
      );
      return;
    }
        
    final profile = UserProfile(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      gender: _selectedGender,
      dob: _dateController.text.trim(),
      job: _selectedJob,
      avatar: _selectedAvatar,
    );

    await profile.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _setOnboardingCompleted() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_completed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea widget to avoid system UI overlaps
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView( //to scroll vertically if the content is bigger than the screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Let\'s know you better',
                        style: TextStyle(
                          color: Colors.black, //UNA VOLTA MESSO LO SFONDO SARA' DA CAMBIARE IN BIANCO
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Name',
                              hintText: 'Enter your name',
                            ),
                            //validator: (value) { //this function is run when validate() is invoked
                              //if (value == null || value.isEmpty) {
                                //return 'Please enter your name';
                              //}
                              //return null; //it means the field was filled out, so it is considered valid
                            //},
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Surname',
                              hintText: 'Enter your surname',
                            ),
                            //validator: (value) { 
                              //if (value == null || value.isEmpty) {
                                //return 'Please enter your surname';
                              //}
                              //return null; 
                            //},
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Nickname',
                              hintText: 'Choose your nickname',
                            ),
                            //validator: (value) { 
                              //if (value == null || value.isEmpty) {
                                //return 'Please choose a nickname';
                              //}
                              //return null; 
                            //},
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>( //creates a dropdown nput field 
                            decoration: InputDecoration(
                              labelText: 'Sex',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: _selectedGender,
                            items: ['M', 'F', 'Other'].map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender, //the actual data stored
                                child: Text(gender), //what the user sees
                              );
                            }).toList(), //toList() turns the map() result into a real list for the dropdown
                            onChanged: (value) => setState(() => _selectedGender = value),
                            //validator: (value) => value == null ? 'Choose gender' : null, //if no option was selected it returns an error message, if the value was selected it returns null (=valid)
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true, //makes the field non-editable by keyboard; prevents users from typing the date manually
                            decoration: InputDecoration(
                              labelText: 'Date of birth',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onTap: () => _selectDate(context), //when pressed, it calls the _selectDate() method
                            //validator: (value) => value == null || value.isEmpty ? 'Pick a date' : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>( 
                            decoration: InputDecoration(
                              labelText: 'Job',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: _selectedJob,
                            items: ['Student', 'Unemployed', 'Freelancer', 'Engineer', 'Doctor', 'Teacher', 'Lawyer', 'Marketing Specialist', 'Consultant', 'Architect', 'Mechanic', 'Electrician', 'Plumber', 'Artist', 'Police Officer', 'Firefighter', 'Chef', 'Retail Worker', 'Other'].map((job) {
                              return DropdownMenuItem<String>(
                                value: job, //the actual data stored
                                child: Text(job), //what the user sees
                              );
                            }).toList(), 
                            onChanged: (value) => setState(() => _selectedJob = value),
                            //validator: (value) => value == null ? 'Choose a job' : null, 
                          ),
                          const SizedBox(height: 20),
                          AvatarDropdown(
                            selectedAvatar: _selectedAvatar,
                            onChanged: (value) => setState(() => _selectedAvatar = value),
                          ),
                          const SizedBox(height: 20),
                          Row( //with Row() the skip and save button will be aligned even if we add other fields to fill
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await _setOnboardingCompleted();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text('Save'),
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
          ],
        ),
      ),
    );
  }
}
