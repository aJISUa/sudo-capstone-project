import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/app/router/app_router.dart';
import 'package:oncare/app/router/routes.dart';
import 'package:oncare/features/auth/presentation/controllers/session_controller.dart';

void main() {
  group('sessionRedirect (router login guard)', () {
    test('signed-out on a protected route → forced to sign-in', () {
      expect(
        sessionRedirect(SessionStatus.signedOut, AppRoutes.dashboard),
        AppRoutes.signIn,
      );
      expect(
        sessionRedirect(SessionStatus.signedOut, AppRoutes.myHealth),
        AppRoutes.signIn,
      );
      expect(
        sessionRedirect(SessionStatus.signedOut, AppRoutes.aiCoach),
        AppRoutes.signIn,
      );
    });

    test('still-restoring (unknown) is guarded exactly like signed-out', () {
      expect(
        sessionRedirect(SessionStatus.unknown, AppRoutes.dashboard),
        AppRoutes.signIn,
      );
      expect(sessionRedirect(SessionStatus.unknown, AppRoutes.signIn), isNull);
    });

    test('signed-out already on sign-in → stays put (null)', () {
      expect(
        sessionRedirect(SessionStatus.signedOut, AppRoutes.signIn),
        isNull,
      );
    });

    test('demo / authenticated on sign-in → bounced into the app', () {
      expect(
        sessionRedirect(SessionStatus.demo, AppRoutes.signIn),
        AppRoutes.dashboard,
      );
      expect(
        sessionRedirect(SessionStatus.authenticated, AppRoutes.signIn),
        AppRoutes.dashboard,
      );
    });

    test('demo / authenticated on a protected route → stays put (null)', () {
      expect(sessionRedirect(SessionStatus.demo, AppRoutes.dashboard), isNull);
      expect(
        sessionRedirect(SessionStatus.authenticated, AppRoutes.exercise),
        isNull,
      );
    });
  });
}
