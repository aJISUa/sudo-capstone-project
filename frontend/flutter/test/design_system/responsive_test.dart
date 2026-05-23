import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/design_system/responsive/responsive_builder.dart';
import 'package:oncare/design_system/tokens/breakpoints.dart';

void main() {
  group('ResponsiveBuilder.selectFormFor', () {
    test('width < tablet breakpoint → mobile', () {
      expect(
        ResponsiveBuilder.selectFormFor(400, hasTablet: true, hasDesktop: true),
        DeviceForm.mobile,
      );
    });

    test('tablet ≤ width < desktop → tablet (when provided)', () {
      expect(
        ResponsiveBuilder.selectFormFor(800, hasTablet: true, hasDesktop: true),
        DeviceForm.tablet,
      );
    });

    test('width ≥ desktop → desktop (when provided)', () {
      expect(
        ResponsiveBuilder.selectFormFor(
          1200,
          hasTablet: true,
          hasDesktop: true,
        ),
        DeviceForm.desktop,
      );
    });

    test('falls back to tablet when desktop branch is missing', () {
      expect(
        ResponsiveBuilder.selectFormFor(
          1400,
          hasTablet: true,
          hasDesktop: false,
        ),
        DeviceForm.tablet,
      );
    });

    test('falls back to mobile when neither tablet nor desktop given', () {
      expect(
        ResponsiveBuilder.selectFormFor(
          1400,
          hasTablet: false,
          hasDesktop: false,
        ),
        DeviceForm.mobile,
      );
    });
  });

  testWidgets('ResponsiveBuilder renders the matching branch widget', (
    tester,
  ) async {
    // The default test surface is 800×600 → tablet range.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            tablet: (_) => const Text('tablet'),
            desktop: (_) => const Text('desktop'),
          ),
        ),
      ),
    );
    expect(find.text('tablet'), findsOneWidget);
  });
}
