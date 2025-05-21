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
  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    if (name != null) await sp.setString('name', name!);
    if (surname != null) await sp.setString('surname', surname!);
    if (nickname != null) await sp.setString('username', nickname!);
    if (gender != null) await sp.setString('gender', gender!);
    if (dob != null) await sp.setString('dob', dob!);
    if (job != null) await sp.setString('job', job!);
    if (avatar != null) await sp.setString('avatar', avatar!);
    await sp.setBool('onboarding_completed', true);
  }
}
