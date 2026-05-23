import 'package:oncare/features/auth/domain/entities/auth_state.dart';

abstract class AuthRepository {
  Future<AuthUser> signIn(AuthProvider provider);
  Future<void> signOut();
}
