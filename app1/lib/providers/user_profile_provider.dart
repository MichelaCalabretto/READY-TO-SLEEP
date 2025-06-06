import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart'; 

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true; //true while it's laoding the infos

  UserProfile? userProfile() => _userProfile; //syntax: returnType (? = could be null) methodName => returned item (=>_userProfile == return userProfile)
  bool isLoading() => _isLoading;   

  UserProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    // notifyListeners(); // Optional here for constructor load

    _userProfile = await UserProfile.load();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profileToSave) async {
    // Set loading true at the beginning of the save operation
    _isLoading = true;
    notifyListeners(); // Notify UI that an operation is in progress

    await profileToSave.save();
    _userProfile = profileToSave; // Update internal state

    _isLoading = false; // Set loading to false after operation completes
    notifyListeners(); // Notify UI about the updated profile and end of loading
  }

  Future<void> updateAvatar(String? newAvatarName) async {
    _isLoading = true;
    notifyListeners();

    if (_userProfile == null) { //if the profile is still not loaded
      await loadProfile(); //load the profile
      if (_userProfile == null) { //if it's still null
         _userProfile = UserProfile(avatar: newAvatarName); //create a new UserProfile instance
                                                            //this new profile will only have the avatar set (and other fields will be null)
                                                            //this means setting an avatar can implicitly create a basic profile record
      } else { //profile was loaded successfully 
        _userProfile!.avatar = newAvatarName; //(!.=non nullable)
      }
    } else { //profile was already loaded at the beginning
      _userProfile!.avatar = newAvatarName;
    }
    
    if (_userProfile != null) {  //saves changes
      await _userProfile!.save();
    }

    _isLoading = false;
    notifyListeners();
  }
}