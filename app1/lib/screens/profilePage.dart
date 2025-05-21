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
      const SnackBar(content: Text('Profile updated')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: 'Surname'),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: 'Nickname'),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Gender'),
                      value: _gender,
                      items: ['M', 'F', 'Other']
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Date of Birth'),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Job'),
                      value: _job,
                      items: [
                        'Student', 'Unemployed', 'Freelancer', 'Engineer', 'Doctor',
                        'Teacher', 'Lawyer', 'Marketing Specialist', 'Consultant',
                        'Architect', 'Mechanic', 'Electrician', 'Plumber', 'Artist',
                        'Police Officer', 'Firefighter', 'Chef', 'Retail Worker', 'Other'
                      ].map((job) => DropdownMenuItem(
                            value: job,
                            child: Text(job),
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
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
