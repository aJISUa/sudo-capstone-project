// Boot smoke test — the trainer app now starts on the login screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oncare_trainer/app/app.dart';
import 'package:oncare_trainer/core/storage/prefs_provider.dart';

void main() {
  testWidgets('boots to the trainer login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const OncareTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('온케어 트레이너'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인 없이 데모 둘러보기'), findsOneWidget);
  });
}
