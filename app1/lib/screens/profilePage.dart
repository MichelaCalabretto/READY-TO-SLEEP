import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/widgets/avatar_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:app1/providers/user_profile_provider.dart';
import 'package:app1/models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  String? _job;
  String? _avatar;

  // This flag helps initialize form data from the provider only once
  bool _isDataInitialized = false;

  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68); // reference color

  // initState no longer calls _loadUserProfile directly.
  // Data will be consumed from the provider in the build method.
  @override
  void initState() {
    super.initState();
    //_loadUserProfile();
  }

  @override 
  void dispose() { //GOOD PRACTICE...LET'S SEE IF WE WANT TO KEEP THIS PART
    // Dispose controllers to free up resources
    _nameController.dispose();
    _surnameController.dispose();
    _nicknameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Helper method to initialize form fields from UserProfile data
  void _initializeFormData(UserProfile? profile) {
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _surnameController.text = profile.surname ?? '';
      _nicknameController.text = profile.nickname ?? '';
      _dobController.text = profile.dob ?? ''; // UserProfile stores dob as String "dd/MM/yyyy"
      _gender = profile.gender;
      _job = profile.job;
      _avatar = profile.avatar;
      _isDataInitialized = true; // Mark as initialized
    }
  }

  /*Future<void> _loadUserProfile() async {
    final profile = await UserProfile.load();
    setState(() {
      _nameController.text = profile.name ?? '';
      _surnameController.text = profile.surname ?? '';
      _nicknameController.text = profile.nickname ?? '';
      _dobController.text = profile.dob ?? '';
      _gender = profile.gender;
      _job = profile.job;
      _avatar = profile.avatar;
      _loading = false;
    });
  }*/

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return; //validate the form first

    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false); //get an instance of the provider

    final updatedProfile = UserProfile(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      surname: _surnameController.text.trim().isEmpty ? null : _surnameController.text.trim(),
      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      dob: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
      gender: _gender,
      job: _job,
      avatar: _avatar,
    );

    // Use the provider to save the profile
    // This will handle the actual saving and notify listeners (e.g., HomePage)
    await userProfileProvider.saveProfile(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255, 192, 153, 227),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        duration: Duration(seconds: 2),
        content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height for background

    // Use Consumer to listen to UserProfileProvider for data and loading state
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        // Get the current profile and loading state from the provider using method calls
        final UserProfile? currentUserProfile = userProfileProvider.userProfile();
        final bool isLoadingProfile = userProfileProvider.isLoading();

        // Initialize form data ONCE:
        // - when the profile data is available from the provider (currentUserProfile != null)
        // - AND local form data hasn't been initialized yet (_isDataInitialized == false)
        // - AND the provider is not in its overall initial loading phase (isLoadingProfile == false)
        //   (This last check ensures we use stable data after the initial load completes)
        if (currentUserProfile != null && !_isDataInitialized && !isLoadingProfile) {
          // Use WidgetsBinding to schedule this after the current build cycle,
          // which is safer if _initializeFormData were to call setState or affect layout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) { // Ensure widget is still mounted before initializing
              setState((){
                _initializeFormData(currentUserProfile);
              });      
            }
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true, // extend background behind app bar
          appBar: AppBar(
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent, // transparent app bar
            elevation: 0,
            foregroundColor: Colors.white, // white text color for title and icons (like back button)
          ),
          body: Stack(
            children: [
              // Background image covering entire screen
              SizedBox(
                height: screenHeight,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/welcomePage_wallpaper.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Content overlay with SafeArea for insets
              SafeArea(
                // Show loading indicator if provider is loading AND local form data hasn't been initialized yet
                // This covers the initial load of the profile data
                child: (isLoadingProfile && !_isDataInitialized)
                    ? const Center(child: CircularProgressIndicator(color: Colors.white,)) // White spinner
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [

                              // Name TextFormField 
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder( // General border
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Surname TextFormField 
                              TextFormField(
                                controller: _surnameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Surname',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Nickname TextFormField 
                              TextFormField(
                                controller: _nicknameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Nickname',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Gender DropdownButtonFormField 
                              DropdownButtonFormField<String>(
                                dropdownColor: darkPurple,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: _gender,
                                items: ['M', 'F', 'Other']
                                    .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g, style: const TextStyle(color: Colors.white)),
                                        ))
                                    .toList(),
                                onChanged: (value) => setState(() => _gender = value),
                                style: const TextStyle(color: Colors.white), // Style for selected item in field
                                iconEnabledColor: Colors.white, // Style for dropdown arrow
                              ),
                              const SizedBox(height: 15),

                              // Date of Birth TextFormField (Your original InputDecoration style)
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),  
                                ),
                                onTap: _selectDate,
                              ),
                              const SizedBox(height: 15),

                              // Job DropdownButtonFormField (
                              DropdownButtonFormField<String>(
                                dropdownColor: darkPurple,
                                decoration: InputDecoration(
                                  labelText: 'Job',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: _job,
                                items: [
                                  'Student', 'Unemployed', 'Freelancer', 'Engineer', 'Doctor',
                                  'Teacher', 'Lawyer', 'Marketing Specialist', 'Consultant',
                                  'Architect', 'Mechanic', 'Electrician', 'Plumber', 'Artist',
                                  'Police Officer', 'Firefighter', 'Chef', 'Retail Worker', 'Other'
                                ].map((jobValue) => DropdownMenuItem(
                                      value: jobValue,
                                      child: Text(jobValue, style: const TextStyle(color: Colors.white)),
                                    ))
                                    .toList(),
                                onChanged: (value) => setState(() => _job = value),
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.white,
                              ),
                              const SizedBox(height: 15),

                              // AvatarDropdown
                              AvatarDropdown(
                                selectedAvatar: _avatar,
                                onChanged: (value) => setState(() => _avatar = value),
                              ),
                              const SizedBox(height: 30),

                              // Save Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: darkPurple,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: _saveProfile, // method to save profile data via provider
                                child: const Text('Save Changes'),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
