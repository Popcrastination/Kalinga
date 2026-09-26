// Kalinga's entry point, following this template's convention: DevicePreview
// stays wrapped around the whole app (including in the deployed build), so
// the live link is judged at phone size instead of stretched across a
// desktop window. See START-HERE.md if you want to drop the frame later.

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'theme.dart';

void main() {
  // TODO(setup): initialize Supabase here, before runApp, once the
  // supabase_flutter package is added (`flutter pub add supabase_flutter`):
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Supabase.initialize(
  //     url: const String.fromEnvironment('SUPABASE_URL'),
  //     anonKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  //   );
  // SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are read from --dart-define at
  // build time (see .env.example and .github/workflows/deploy-web.yml) —
  // never hardcode them here.
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const KalingaApp(),
    ),
  );
}

class KalingaApp extends StatelessWidget {
  const KalingaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalinga',
      debugShowCheckedModeBanner: false,

      // Required for the DevicePreview toolbar to actually control the app.
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: kalingaTheme,
      home: const LoginPage(),
    );
  }
}
