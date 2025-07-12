import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/widgets/meal_entry_dialog.dart';

// Helper to format sleep duration into "X h Y min"
String _formatSleepDurationHelper(int totalMinutes) {
  if (totalMinutes <= 0) return "0 h 0 min"; 
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;
  return '$hours h $minutes min';
}

class UserGreetingWithAvatar extends StatelessWidget {
  final UserProfile? currentUserProfile; // for the avatar to be shown
  final SleepDataNight? previousNightSleep; // this will be yesterday's specific data if loaded
  final bool isLoadingSleep; // parameter to indicate if yesterday's sleep data is being loaded

  const UserGreetingWithAvatar({
    Key? key,
    required this.currentUserProfile,
    this.previousNightSleep, // optional as it might be null while loading or if no data
    this.isLoadingSleep = false, // default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator if yesterday's sleep data is currently being fetched
    if (isLoadingSleep) {
      return Center( // center the loading indicator
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white.withOpacity(0.7)),
            const SizedBox(height: 10),
            const Text("Loading last night's sleep...", style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    // Determine the base name for the avatar image
    String avatarBaseName = currentUserProfile?.avatar?.isNotEmpty == true // safe access to the avatar as it might not be selected (=null)
        ? currentUserProfile!.avatar!
        : 'cat'; // default avatar if none selected by the user

    // Safely get sleep duration in minutes; defaults to 0 if no data
    int sleepMinutes = previousNightSleep?.duration ?? 0; // if no duration was registered, returns 0
    // Convert sleep duration to hours for logical comparisons and display
    double sleepHoursActual = sleepMinutes / 60.0; // condition for different text display

    // Determine avatar mood based on sleep hours
    bool isHappy = previousNightSleep != null && sleepHoursActual >= 7;
    String avatarMoodPrefix = isHappy ? 'happy' : 'sad';
    String neutralAvatarPath = 'images/avatars/${avatarBaseName}.png'; 
    String ultimateFallbackAvatarPath = 'images/avatars/sad_cat.gif'; 

    // Construct paths for avatar images
    String primaryAvatarPath = 'images/avatars/${avatarMoodPrefix}_${avatarBaseName}.gif'; 

    String greetingMessage; 
    String formattedDuration = _formatSleepDurationHelper(sleepMinutes); 

    if (previousNightSleep == null) {
      greetingMessage = "Couldn't retrieve last night's sleep data. How about planning a healthy dinner for tonight?";
      avatarMoodPrefix = 'sad'; 
      primaryAvatarPath = 'images/avatars/${avatarMoodPrefix}_${avatarBaseName}.gif'; 
    } else if (sleepMinutes <= 0) {
      greetingMessage = "It seems no sleep was recorded for last night. A nutritious dinner today might set you up for better rest!";
    } else if (sleepHoursActual < 5) {
      greetingMessage =
          "Last night you only slept $formattedDuration. That's not much! Let's focus on a balanced dinner to help you get more restful sleep tonight.";
    } else if (sleepHoursActual < 7) { 
      greetingMessage =
          "You slept $formattedDuration last night. Good effort! Fueling well with dinner today could help improve your sleep quality.";
    } else { // sleepHoursActual >= 7
      greetingMessage =
          "Fantastic! You slept $formattedDuration last night. You're doing great! Let's keep the momentum going with a thoughtful dinner choice today.";
    }

    // UI styling constants
    final bubbleColor = Colors.white.withOpacity(0.9); 
    final textColor = Color.fromARGB(255, 38, 9, 68); 

    // Define the visual size of the avatar (the circular crop area)
    const double avatarDisplaySize = 120.0; 
    // Define the actual size of the image asset to be loaded (larger for zoom effect)
    double avatarImageSourceSize; // this is larger than avatarDisplaySize for zoom
    if (avatarBaseName == 'fox') {
      avatarImageSourceSize = 210.0; // use a smaller source size for the fox
    } else {
      avatarImageSourceSize = 250.0; // use the default larger size for all other avatars
    } 

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // vertically align avatar and bubble at the center
      children: [
        // Avatar Section (takes 1/3 of the space)
        Expanded(
          flex: 1, // avatar takes 1 part of the available space
          child: Center( // center the avatar within its expanded space
            child: SizedBox(
              width: avatarDisplaySize,
              height: avatarDisplaySize,
              child: ClipOval(
                child: OverflowBox(
                  // Allow the image to be larger than the ClipOval
                  minWidth: avatarImageSourceSize, 
                  minHeight: avatarImageSourceSize,
                  maxWidth: avatarImageSourceSize,
                  maxHeight: avatarImageSourceSize,
                  child: Image.asset(
                    primaryAvatarPath,
                    width: avatarImageSourceSize, // use the larger source size
                    height: avatarImageSourceSize, // use the larger source size
                    fit: BoxFit.cover, // scales the image so that it completely covers the box without distorting it
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        neutralAvatarPath,
                        width: avatarImageSourceSize,
                        height: avatarImageSourceSize,
                        fit: BoxFit.cover,
                        // Fallback in case of problems in loading the avatar (---> when there is no sleepData for yesterday night)
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ultimateFallbackAvatarPath,
                            width: avatarImageSourceSize,
                            height: avatarImageSourceSize,
                            fit: BoxFit.cover,
                          );
                        }
                      );
                    }   
                  ),
                ),
              ),
            ),
          ),
        ),

        // Spacing between avatar and text bubble
        const SizedBox(width: 10.0), 

        // Text Bubble Section (takes 2/3 of the space)
        Expanded(
          flex: 2, // text bubble takes 2 parts of the available space
          child: Container(
            // Added a margin on the right to align this bubble's background with the ChartSwitcher's content area background
            margin: const EdgeInsets.only(right: 16.0), 
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0), // internal padding for the bubble's content
            decoration: BoxDecoration(
              color: bubbleColor, 
              borderRadius: BorderRadius.circular(15.0), 
              boxShadow: [ // adds a soft shadow effect behind the bubble widget
                BoxShadow( 
                  color: Colors.black.withOpacity(0.15), 
                  blurRadius: 6, // higher the number, softer and more spread-out the shadow
                  offset: const Offset(0, 3), // moves the shadow 3 pixels downward, with no horizontal shift (0 on the X-axis)
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Center the greeting text horizontally
                // Wrap Text with Flexible to prevent overflow inside Row
                Flexible( // allows greeting text to wrap and shrink within available space
                  child: Center(
                    child: SingleChildScrollView( // SingleChildScrollView to make the greeting text scrollable vertically
                      scrollDirection: Axis.vertical, // set scroll direction to vertical
                      child: Text(
                        greetingMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Meal button aligned to the right
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      MealEntryDialog.show(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor, // color of the button (darkPurple)
                      foregroundColor: Colors.white, // color of the text
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    child: const Text("Record Today's Dinner"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}