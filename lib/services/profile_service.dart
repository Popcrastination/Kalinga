import '../models/user_profile.dart';
import 'supabase_config.dart';

class ProfileService {
  static Future<UserProfile> fetch(String userId) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromMap(row);
  }

  static Future<void> updateHeightAndWeight({
    required String userId,
    required double heightCm,
    required double weightKg,
  }) {
    return supabase
        .from('profiles')
        .update({'height_cm': heightCm, 'weight_kg': weightKg})
        .eq('id', userId);
  }
}
