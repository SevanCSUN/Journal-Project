import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:device_preview/device_preview.dart';
import 'src/sample_feature/landing_page.dart';
import 'src/settings/settings_view.dart'; // Import SettingsView
import 'src/sample_feature/login_page.dart'; // Import LoginPage

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  //this code snippet below is needed to not use the device preview sim. replace this when we're ready to release/test
  // runApp(MyApp(settingsController: settingsController));
  
  //look at app.dart line 31 for other snippets to remove.
  //lastly, the device preview dependancy was added to the pubspec.yaml file. this does not need to be removed.

  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(settingsController: settingsController), // Wrap your app
  ));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          case '/':
          default:
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) => const LandingPage(),
            );
        }
      },
    );
  }
}