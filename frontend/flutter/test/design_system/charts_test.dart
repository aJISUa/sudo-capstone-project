import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/design_system/charts/app_bar_chart.dart';
import 'package:oncare/design_system/charts/app_donut_chart.dart';
import 'package:oncare/design_system/charts/app_line_chart.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 300, height: 200, child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('AppLineChart builds a LineChart', (t) async {
    await _pump(
      t,
      const AppLineChart(
        spots: <FlSpot>[FlSpot(0, 1), FlSpot(1, 2), FlSpot(2, 1.5)],
      ),
    );
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('AppBarChart builds a BarChart', (t) async {
    await _pump(t, const AppBarChart(values: <double>[1, 2, 3]));
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('AppDonutChart builds a PieChart with a legend', (t) async {
    await _pump(
      t,
      const AppDonutChart(
        segments: <AppDonutSegment>[
          AppDonutSegment(label: 'A', value: 1, color: Colors.red),
          AppDonutSegment(label: 'B', value: 2, color: Colors.green),
        ],
      ),
    );
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('A (1)'), findsOneWidget);
    expect(find.text('B (2)'), findsOneWidget);
  });
}
