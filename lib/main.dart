// Kalinga's entry point, following this template's convention: DevicePreview
// stays wrapped around the whole app (including in the deployed build), so
// the live link is judged at phone size instead of stretched across a
// desktop window. See START-HERE.md if you want to drop the frame later.

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'screens/dashboard_page.dart';
import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'services/supabase_config.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

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
      // Supabase persists the session locally, so a returning signed-in
      // user skips straight past Login rather than being asked to sign in
      // again every time they open the app.
      home: AuthService.isSignedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
