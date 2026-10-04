/// Mirrors a row in Supabase's `profiles` table (see docs/01-proposal.md).
/// `id` matches the Supabase Auth user id — profiles are created right
/// after sign-up, not before, since the id only exists once auth succeeds.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.heightCm,
    required this.weightKg,
  });

  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth; // stored as MM/DD/YYYY text, matching the form
  final double heightCm;
  final double weightKg;

  String get fullName => '$firstName $lastName';

  /// Age in whole years, computed from [dateOfBirth] (MM/DD/YYYY) — so it
  /// stays correct as time passes instead of being a stored number that
  /// goes stale on the user's birthday.
  int get age {
    final parts = dateOfBirth.split('/');
    final birth = DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final now = DateTime.now();
    var years = now.year - birth.year;
    final hadBirthdayThisYear = now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthdayThisYear) years--;
    return years;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      heightCm: (map['height_cm'] as num).toDouble(),
      weightKg: (map['weight_kg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'id': id,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'height_cm': heightCm,
        'weight_kg': weightKg,
      };
}
