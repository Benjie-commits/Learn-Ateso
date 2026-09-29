import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_ateso/app.dart';

void main() {
  testWidgets('App boots to the onboarding screen', (tester) async {
    await tester.pumpWidget(const LearnAtesoApp());
    await tester.pumpAndSettle();

    expect(find.text('Learn Ateso'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
