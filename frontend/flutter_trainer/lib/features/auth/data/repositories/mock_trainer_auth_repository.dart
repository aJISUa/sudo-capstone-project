import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare_trainer/features/auth/domain/repositories/trainer_auth_repository.dart';

/// Pure in-memory mock used until the FastAPI backend exists.
///
/// Accepts any non-empty email/password (mirroring the user app's demo
/// login) and issues a fake token. No network, no real validation —
/// real credential checks arrive with the backend implementation.
class MockTrainerAuthRepository implements TrainerAuthRepository {
  /// Creates the mock repository.
  const MockTrainerAuthRepository();

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    // Small delay so the UI's loading state is observable.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('이메일과 비밀번호를 입력해 주세요');
    }

    return 'demo-trainer-token-${DateTime.now().microsecondsSinceEpoch}';
  }
}

/// Provides the trainer auth repository. Swapped for a real
/// (dio-backed) implementation when the backend lands.
final trainerAuthRepositoryProvider = Provider<TrainerAuthRepository>((ref) {
  return const MockTrainerAuthRepository();
});
