import 'seeker_profile.dart';
import 'helper_profile.dart';

enum UserRole { seeker, helper }

class AppUser {
  final String id;
  final UserRole role;
  final String ageDecade;
  final SeekerProfile? seekerProfile;
  final HelperProfile? helperProfile;

  AppUser({
    required this.id,
    required this.role,
    required this.ageDecade,
    this.seekerProfile,
    this.helperProfile,
  });
}
