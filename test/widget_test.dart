// A widget test: it builds your app in memory and checks what is on screen.
// Run them all with: flutter test
//
// You are not required to write more of these, but a project with a few real
// tests reads very differently from one with none.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:final_project/main.dart';

void main() {
  // KalingaApp checks AuthService.isSignedIn on build, which reads
  // Supabase.instance.client — so Supabase has to be initialized before
  // any widget test touches KalingaApp, even though no real network call
  // happens in this test. Fake, harmless values are enough: nothing here
  // actually reaches a server.
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('Login screen shows the Kalinga logo and both actions', (
    tester,
  ) async {
    // Build the app. Note we build KalingaApp directly, not the
    // DevicePreview wrapper, because a test does not need the phone frame.
    await tester.pumpWidget(const KalingaApp());

    // The wordmark is an image now (assets/images/kalinga_logo.png), not
    // literal text — check for the Image widget instead of find.text.
    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Register'), findsOneWidget);

    // Submitting the form empty should surface validation instead of
    // calling AuthService at all.
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
  });
}
