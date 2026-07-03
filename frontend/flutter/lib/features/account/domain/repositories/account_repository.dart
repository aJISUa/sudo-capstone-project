import 'package:oncare/features/account/domain/entities/user_profile.dart';

abstract class AccountRepository {
  Future<UserProfile> fetchProfile();

  /// PUT /users/me — update basic profile (name/email/phone/birth).
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
  });

  /// PUT /users/me/health-goals — update goal targets.
  Future<UserProfile> updateHealthGoals({
    num? goalWeightKg,
    int? goalBpSystolic,
    int? goalBloodSugar,
    int? dailyCalories,
    int? dailySodiumMg,
  });
}
