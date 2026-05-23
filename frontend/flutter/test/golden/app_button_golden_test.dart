@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/design_system/atoms/app_button.dart';
import 'package:oncare/design_system/theme/app_theme.dart';

void main() {
  testWidgets('AppButton variants (golden)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppButton(label: 'Primary', onPressed: () {}),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Secondary',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Ghost',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                const AppButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_variants.png'),
    );
  }, tags: <String>['golden']);
}
