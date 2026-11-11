import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_gtbiluan_acandrade/main.dart';

void main() {
  testWidgets('Expense tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PersonalExpenseTrackerApp());

    // Verify app starts up (shows auth or main screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
