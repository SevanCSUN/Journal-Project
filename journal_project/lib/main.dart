import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as firebase_options;

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:device_preview/device_preview.dart';
import 'src/sample_feature/landing_page.dart';
import 'src/settings/settings_view.dart'; // Import SettingsView
import 'src/sample_feature/login_page.dart'; // Import LoginPage
import 'src/settings/account_settings_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized to avoid duplication
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: firebase_options.DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Log any Firebase initialization errors
      debugPrint('Firebase initialization error: $e');
    }
  } else {
    debugPrint('Firebase app already initialized.');
  }

  // Set up the SettingsController
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Run the app with DevicePreview for development/testing
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(settingsController: settingsController),
  ));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, child) {
        return MaterialApp(
          themeMode: settingsController.themeMode,
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const LoginPage(),
          onGenerateRoute: (RouteSettings routeSettings) {
            switch (routeSettings.name) {
              case SettingsView.routeName:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => SettingsView(controller: settingsController),
                );
              case AccountSettingsView.routeName:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const AccountSettingsView(),
                );
              case '/':
              default:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const LandingPage(),
                );
            }
          },
        );
      },
    );
  }
}
