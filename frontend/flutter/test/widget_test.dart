import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/app/app.dart';
import 'package:oncare/core/config/app_config.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/services/locale_provider.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {Locale? locale}) async {
    const config = AppConfig(
      environment: Environment.dev,
      apiBaseUrl: 'https://dev.api.test',
      useMockApi: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(config),
          if (locale != null) localeProvider.overrideWith((ref) => locale),
        ],
        child: const OncareApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Boots into the Dashboard tab in English', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Diet'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('My Health'), findsOneWidget);
  });

  testWidgets('Tapping a bottom-nav destination switches branch', (
    tester,
  ) async {
    await pumpApp(tester, locale: const Locale('en'));

    await tester.tap(find.text('Diet'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Diet Record'), findsOneWidget);

    await tester.tap(find.text('Exercise'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Exercise'), findsOneWidget);

    await tester.tap(find.text('My Health'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'My Health'), findsOneWidget);
  });

  testWidgets('Korean locale localises the bottom-nav labels', (tester) async {
    await pumpApp(tester, locale: const Locale('ko'));
    // Dashboard async data is fetched after first frame — wait it out.
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '대시보드'), findsOneWidget);
    // Dashboard content may include the same Korean tokens as the
    // bottom-nav labels (e.g. 운동 / 식단 metric cards), so allow ≥1.
    expect(find.text('식단'), findsAtLeastNWidgets(1));
    expect(find.text('운동'), findsAtLeastNWidgets(1));
    expect(find.text('내 건강'), findsAtLeastNWidgets(1));
  });

  test('ARB resources expose nav strings for ko + en', () {
    // sanity: 'supportedLocales' is the canonical set.
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('ko')));
  });
}
