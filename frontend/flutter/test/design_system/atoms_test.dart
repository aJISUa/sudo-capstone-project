import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/design_system/atoms/app_avatar.dart';
import 'package:oncare/design_system/atoms/app_badge.dart';
import 'package:oncare/design_system/atoms/app_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('primary renders a FilledButton', (t) async {
      await _pump(t, AppButton(label: 'Go', onPressed: () {}));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('secondary renders an OutlinedButton', (t) async {
      await _pump(
        t,
        AppButton(
          label: 'Go',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ghost renders a TextButton', (t) async {
      await _pump(
        t,
        AppButton(
          label: 'Go',
          variant: AppButtonVariant.ghost,
          onPressed: () {},
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('null onPressed disables the button', (t) async {
      await _pump(t, const AppButton(label: 'Go', onPressed: null));
      final btn = t.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('AppBadge', () {
    testWidgets('label is rendered', (t) async {
      await _pump(t, const AppBadge(label: 'Beta', tone: AppBadgeTone.info));
      expect(find.text('Beta'), findsOneWidget);
    });
  });

  group('AppAvatar', () {
    testWidgets('renders initials when no image url is given', (t) async {
      await _pump(t, const AppAvatar(label: 'Subin Lee'));
      expect(find.text('SL'), findsOneWidget);
    });
  });
}
