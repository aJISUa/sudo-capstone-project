// Scaffold smoke test — verifies the trainer app boots to its
// placeholder landing screen with the design tokens wired up.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare_trainer/app/app.dart';

void main() {
  testWidgets('boots to the trainer scaffold landing screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: OncareTrainerApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('온케어 트레이너'), findsOneWidget);
  });
}
