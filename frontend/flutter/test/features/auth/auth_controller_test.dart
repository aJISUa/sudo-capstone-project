import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/auth/domain/entities/auth_state.dart';
import 'package:oncare/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  test('starts signed out', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final v = container.read(authControllerProvider);
    expect(v.value?.isSignedIn, isFalse);
  });

  test('signIn(provider) ends up signed in with that provider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(authControllerProvider.notifier)
        .signIn(AuthProvider.kakao);
    final v = container.read(authControllerProvider);
    expect(v.value?.isSignedIn, isTrue);
    expect(v.value?.user?.provider, AuthProvider.kakao);
  });

  test('signOut returns to signed-out state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctl = container.read(authControllerProvider.notifier);
    await ctl.signIn(AuthProvider.google);
    await ctl.signOut();
    expect(container.read(authControllerProvider).value?.isSignedIn, isFalse);
  });
}
