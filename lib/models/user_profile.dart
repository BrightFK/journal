// lib/models/user_profile.dart
import 'package:mindmeld_ai/extentions.dart';

part 'user_profile.g.dart'; // We will generate this

@HiveType(typeId: 2) // New unique typeId (0=JournalEntry, 1=AIAnalysis)
class UserProfile extends HiveObject {
  // We use a known key so we can easily find the *one and only* profile.
  static const String singletonKey = 'userProfile';

  @HiveField(0)
  String name;

  // We will store the path to the image, not the image itself, for efficiency.
  @HiveField(1)
  String? imagePath;

  UserProfile({required this.name, this.imagePath});
}
