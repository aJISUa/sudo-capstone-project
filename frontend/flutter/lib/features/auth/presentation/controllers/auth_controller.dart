import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:oncare/features/auth/domain/entities/auth_state.dart';
import 'package:oncare/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const MockAuthRepository(),
  name: 'authRepository',
);

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this._repo)
    : super(const AsyncValue<AuthState>.data(AuthState()));

  final AuthRepository _repo;

  Future<void> signIn(AuthProvider provider) async {
    state = const AsyncValue<AuthState>.loading();
    try {
      final user = await _repo.signIn(provider);
      state = AsyncValue<AuthState>.data(AuthState(user: user));
    } catch (e, st) {
      state = AsyncValue<AuthState>.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue<AuthState>.data(AuthState());
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
      name: 'auth',
    );
