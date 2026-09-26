// A widget test: it builds your app in memory and checks what is on screen.
// Run them all with: flutter test
//
// You are not required to write more of these, but a project with a few real
// tests reads very differently from one with none.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';

void main() {
  testWidgets('Login screen shows the Kalinga wordmark and both actions', (
    tester,
  ) async {
    // Build the app. Note we build KalingaApp directly, not the
    // DevicePreview wrapper, because a test does not need the phone frame.
    await tester.pumpWidget(const KalingaApp());

    expect(find.text('Kalinga'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Register'), findsOneWidget);

    // Submitting the form empty should surface validation instead of
    // navigating away.
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
  });
}
