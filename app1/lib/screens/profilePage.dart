import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/widgets/avatar_dropdown.dart';

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

  bool _loading = true;

  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68); // reference color

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = UserProfile(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _gender,
      job: _job,
      avatar: _avatar,
    );

    await updatedProfile.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255, 192, 153, 227),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        duration: Duration(seconds: 2),
        content: Text('Profile updated')),
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true, // extend background behind app bar
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // transparent app bar
        elevation: 0,
        foregroundColor: Colors.white, // white text color matching onboardingPage
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
            child: _loading //loads the user data
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
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
                          ),
                          const SizedBox(height: 15),
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
                            ),
                            onTap: _selectDate,
                          ),
                          const SizedBox(height: 15),
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
                            ].map((job) => DropdownMenuItem(
                                  value: job,
                                  child: Text(job, style: const TextStyle(color: Colors.white)),
                                ))
                                .toList(),
                            onChanged: (value) => setState(() => _job = value),
                          ),
                          const SizedBox(height: 15),
                          AvatarDropdown(
                            selectedAvatar: _avatar,
                            onChanged: (value) => setState(() => _avatar = value),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: darkPurple,
                            ),
                            onPressed: _saveProfile,
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
