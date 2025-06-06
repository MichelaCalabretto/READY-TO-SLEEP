import 'package:flutter/material.dart';
import 'package:app1/models/user_profile.dart';
import 'package:app1/models/sleep_data_night.dart';

// Helper to format sleep duration into "X h Y min"
String _formatSleepDurationHelper(int totalMinutes) {
  if (totalMinutes <= 0) return "0 h 0 min"; 
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;
  return '${hours} h ${minutes} min';
}

class UserGreetingWithAvatar extends StatelessWidget {
  final UserProfile? currentUserProfile;
  final SleepDataNight? previousNightSleep; // This will be yesterday's specific data if loaded
  final bool isLoadingSleep; // Parameter to indicate if yesterday's sleep data is being loaded

  const UserGreetingWithAvatar({
    Key? key,
    required this.currentUserProfile,
    this.previousNightSleep, // Optional as it might be null while loading or if no data
    this.isLoadingSleep = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator if yesterday's sleep data is currently being fetched.
    if (isLoadingSleep) {
      return Center( // Center the loading indicator
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

    // Determine the base name for the avatar image.
    String avatarBaseName = currentUserProfile?.avatar?.isNotEmpty == true
        ? currentUserProfile!.avatar!
        : 'cat'; // Default avatar if none selected by the user.

    // Safely get sleep duration in minutes; defaults to 0 if no data.
    int sleepMinutes = previousNightSleep?.duration ?? 0; //if no duration was registered, returns 0.
    // Convert sleep duration to hours for logical comparisons and display.
    double sleepHoursActual = sleepMinutes / 60.0; //condition for different text display.

    // Determine avatar mood based on sleep hours.
    bool isHappy = previousNightSleep != null && sleepHoursActual >= 7;
    String avatarMoodPrefix = isHappy ? 'happy' : 'sad';

    // Construct paths for avatar images.
    String primaryAvatarPath = 'images/avatars/${avatarMoodPrefix}_${avatarBaseName}.gif'; 
    String neutralAvatarPath = 'images/avatars/${avatarBaseName}.png'; 
    String ultimateFallbackAvatarPath = 'images/avatars/sad_cat.gif'; 

    String greetingMessage; 
    String formattedDuration = _formatSleepDurationHelper(sleepMinutes); 

    if (previousNightSleep == null) {
      greetingMessage = "Couldn't retrieve last night's sleep data. How about planning a healthy dinner for tonight?";
      avatarMoodPrefix = 'sad'; 
      primaryAvatarPath = 'images/avatars/${avatarMoodPrefix}_${avatarBaseName}.png'; 
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
    // Define the actual size of the image asset to be loaded (larger for "zoom" effect)
    const double avatarImageSourceSize = 250.0; // This should be larger than avatarDisplaySize for zoom

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Vertically align avatar and bubble
      children: [
        // Avatar Section (takes 1/3 of the space)
        Expanded(
          flex: 1, // Avatar takes 1 part of the available space
          child: Center( // Center the avatar within its expanded space
            child: SizedBox(
              width: avatarDisplaySize,
              height: avatarDisplaySize,
              child: ClipOval(
                child: OverflowBox(
                  // Allow the image to be larger than the ClipOval
                  minWidth: avatarImageSourceSize, // Ensure OverflowBox is at least this big
                  minHeight: avatarImageSourceSize,
                  maxWidth: avatarImageSourceSize,
                  maxHeight: avatarImageSourceSize,
                  child: Image.asset(
                    primaryAvatarPath,
                    width: avatarImageSourceSize, // Use the larger source size
                    height: avatarImageSourceSize, // Use the larger source size
                    fit: BoxFit.cover, // Cover the OverflowBox, will be clipped by ClipOval
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        neutralAvatarPath,
                        width: avatarImageSourceSize,
                        height: avatarImageSourceSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ultimateFallbackAvatarPath,
                            width: avatarImageSourceSize,
                            height: avatarImageSourceSize,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        // Spacing between avatar and text bubble
        const SizedBox(width: 10.0), // Adjust this for desired closeness
        // Text Bubble Section (takes 2/3 of the space)
        Expanded(
          flex: 2, // Text bubble takes 2 parts of the available space
          child: Container(
            // Add a margin on the right to align this bubble's background
            // with the ChartSwitcher's content area background.
            // This assumes ChartSwitcher has an internal padding of 16.
            margin: const EdgeInsets.only(right: 16.0), 
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0), // Internal padding for the bubble's content
            decoration: BoxDecoration(
              color: bubbleColor, 
              borderRadius: BorderRadius.circular(15.0), 
              boxShadow: [
                BoxShadow( 
                  color: Colors.black.withOpacity(0.15), 
                  blurRadius: 6, 
                  offset: const Offset(0, 3), 
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  greetingMessage,
                  style: TextStyle(
                    color: textColor, 
                    fontSize: 14.5, 
                    fontWeight: FontWeight.w500, 
                    height: 1.4, 
                  ),
                ),
                const SizedBox(height: 12), 
                Align(
                  alignment: Alignment.centerRight, 
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add meal dialog functionality to be implemented.'),
                          backgroundColor: Color.fromARGB(255, 192, 153, 227), 
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), 
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13) 
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
