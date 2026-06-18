import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nkwa/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash screen renders title and subtitle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Nkwa'), findsOneWidget);
    expect(find.text('Help, the moment you need it.'), findsOneWidget);

    // Let the splash delay and pending route transition finish cleanly.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Navigates to onboarding when no progress is saved', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Skip'), findsOneWidget);
  });
}
