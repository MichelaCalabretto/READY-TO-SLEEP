import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String? name;
  String? surname;
  String? nickname;
  String? gender;
  String? dob;
  String? job;
  String? avatar;

  UserProfile({
    this.name,
    this.surname,
    this.nickname,
    this.gender,
    this.dob,
    this.job,
    this.avatar,
  });

  // Load data from SharedPreferences
  static Future<UserProfile> load() async {
    final sp = await SharedPreferences.getInstance();
    return UserProfile(
      name: sp.getString('name'),
      surname: sp.getString('surname'),
      nickname: sp.getString('nickname'),
      gender: sp.getString('gender'),
      dob: sp.getString('dob'),
      job: sp.getString('job'),
      avatar: sp.getString('avatar'),
    );
  }

  // Save data on SharedPreferences
  // In lib/models/user_profile.dart
  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    if (name != null && name!.isNotEmpty) { // Also check for isNotEmpty if empty string means "not set"
      await sp.setString('name', name!);
    } else {
      await sp.remove('name'); // Remove key if name is null or empty
    }
    if (surname != null && surname!.isNotEmpty) {
      await sp.setString('surname', surname!);
    } else {
      await sp.remove('surname');
    }
    if (nickname != null && nickname!.isNotEmpty) { 
      await sp.setString('nickname', nickname!);
    } else {
      await sp.remove('nickname');
    }
    if (gender != null) { // Gender is a fixed list, so null means not selected
      await sp.setString('gender', gender!);
    } else {
      await sp.remove('gender');
    }
    if (dob != null && dob!.isNotEmpty) {
      await sp.setString('dob', dob!);
    } else {
      await sp.remove('dob');
    }
    if (job != null) { // Job is a fixed list, so null means not selected
      await sp.setString('job', job!);
    } else {
      await sp.remove('job');
    }
    if (avatar != null) { 
      await sp.setString('avatar', avatar!);
    } else {
      await sp.remove('avatar'); 
    }
    await sp.setBool('onboarding_completed', true);
  }
}
