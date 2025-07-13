import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart'; 

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true; // flag to tell the UI whether the provider is currently fetching or saving data

  UserProfile? userProfile() => _userProfile; // getter methods ----> syntax: returnType (? = could be null) methodName => returned item (=>_userProfile == return userProfile)
  bool isLoading() => _isLoading;   

  UserProfileProvider() { // class constructor that as soon as this provider is created, automatically tries to load the profile from storage 
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners(); 

    _userProfile = await UserProfile.load(); // calls the load() method defined in the user_profile to load it

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profileToSave) async {
    _isLoading = true;
    notifyListeners(); // notify UI that an operation is in progress

    await profileToSave.save(); // save() is the method defined in the user_profile
    _userProfile = profileToSave; // update internal state

    _isLoading = false; 
    notifyListeners(); // notify UI about the updated profile and end of loading
  }

  Future<void> updateAvatar(String? newAvatarName) async {
    _isLoading = true;
    notifyListeners();

    // If the user didn't choose an avatar, the standard one will be shown (cat)
    if (_userProfile == null) { // if the profile is still not loaded
      await loadProfile(); // load the profile
      if (_userProfile == null) { // if it's still null
         _userProfile = UserProfile(avatar: newAvatarName); // create a new UserProfile instance
                                                            // this new profile will only have the avatar set (and other fields will be null)
      } else { // profile was loaded successfully 
        _userProfile!.avatar = newAvatarName; // (!.=non nullable)
      }
    } else { // profile was already loaded at the beginning
      _userProfile!.avatar = newAvatarName;
    }
    
    if (_userProfile != null) {  // saves changes
      await _userProfile!.save();
    }

    _isLoading = false;
    notifyListeners();
  }
}