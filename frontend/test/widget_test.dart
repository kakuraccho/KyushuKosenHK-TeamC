import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_lapse/main.dart';

void main() {
  testWidgets('App renders MainScreen with BottomNavigationBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify BottomNavigationBar items exist
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Shoot'), findsOneWidget);
    expect(find.text('SNS'), findsOneWidget);

    // Verify default tab shows Pomodoro
    expect(find.text('Pomodoro'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
  });
}
