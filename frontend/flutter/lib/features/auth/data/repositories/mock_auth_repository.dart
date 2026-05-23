import 'package:oncare/features/auth/domain/entities/auth_state.dart';
import 'package:oncare/features/auth/domain/repositories/auth_repository.dart';

/// Mock implementation used until the real social SDKs (Apple / Google /
/// Kakao / Naver) are wired in Stage 4 follow-up with real keys.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<AuthUser> signIn(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return AuthUser(
      id: 'mock-${provider.name}-1',
      name: 'Demo (${provider.name})',
      provider: provider,
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}
