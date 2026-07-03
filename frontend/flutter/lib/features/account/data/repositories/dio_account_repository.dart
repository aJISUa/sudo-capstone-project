import 'package:dio/dio.dart';

import 'package:oncare/features/account/domain/entities/user_profile.dart';
import 'package:oncare/features/account/domain/repositories/account_repository.dart';

class DioAccountRepository implements AccountRepository {
  DioAccountRepository(this._dio);
  final Dio _dio;

  @override
  Future<UserProfile> fetchProfile() async {
    final res = await _dio.get<Map<String, Object?>>('/users/me/profile');
    return UserProfile.fromJson(res.data!);
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
  }) async {
    final res = await _dio.put<Map<String, Object?>>(
      '/users/me',
      data: <String, Object?>{
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
        'birth_date': ?birthDate,
      },
    );
    return UserProfile.fromJson(res.data!);
  }

  @override
  Future<UserProfile> updateHealthGoals({
    num? goalWeightKg,
    int? goalBpSystolic,
    int? goalBloodSugar,
    int? dailyCalories,
    int? dailySodiumMg,
  }) async {
    final res = await _dio.put<Map<String, Object?>>(
      '/users/me/health-goals',
      data: <String, Object?>{
        'goal_weight_kg': ?goalWeightKg,
        'goal_bp_systolic': ?goalBpSystolic,
        'goal_blood_sugar': ?goalBloodSugar,
        'daily_calories': ?dailyCalories,
        'daily_sodium_mg': ?dailySodiumMg,
      },
    );
    return UserProfile.fromJson(res.data!);
  }
}
