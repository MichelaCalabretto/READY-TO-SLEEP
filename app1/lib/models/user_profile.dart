import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String? name; // each variable is nullable since the user can skip the onboarding or not fill out all the forms in the profilePage
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

  // Loads data from SharedPreferences
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

  // Saves data on SharedPreferences
  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    if (name != null && name!.isNotEmpty) { // also checks for isNotEmpty because empty string means "not set"
      await sp.setString('name', name!);
    } else {
      await sp.remove('name'); // removes the key if the name is null or empty (the form can be changed from String to empty and needs to be updated)
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
    if (gender != null) { // gender is a fixed list, so null means not selected, it cannot be empty
      await sp.setString('gender', gender!);
    } else {
      await sp.remove('gender');
    }
    if (dob != null && dob!.isNotEmpty) {
      await sp.setString('dob', dob!);
    } else {
      await sp.remove('dob');
    }
    if (job != null) { // job is a fixed list, so null means not selected, it cannot be empty
      await sp.setString('job', job!);
    } else {
      await sp.remove('job');
    }
    if (avatar != null) { // avatar is a fixed list, so null means not selected, it cannot be empty
      await sp.setString('avatar', avatar!);
    } else {
      await sp.remove('avatar'); 
    }
    await sp.setBool('onboarding_completed', true); // everytime the user updates the profile, or when the user fills out the onBoarding, this flag is set to True, so that the onBoarding is shown only once
  }
}
