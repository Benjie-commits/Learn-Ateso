import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_ateso/app.dart';

// This test pumps the full LearnAtesoApp, which constructs real repositories
// via AuthGate. Run with `flutter test --dart-define=USE_FIREBASE=false` so
// it exercises the in-memory fakes instead of needing Firebase.initializeApp()
// (which no test in this suite calls).
void main() {
  testWidgets('App boots to the onboarding screen', (tester) async {
    await tester.pumpWidget(const LearnAtesoApp());
    await tester.pumpAndSettle();

    expect(find.text('Learn Ateso'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
