import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/indiv_page_view.dart';
import 'sample_feature/landing_page.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'sample_feature/login_page.dart';
import 'settings/account_settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // The below lines are for device preview. Remove them when ready to push.
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,

          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey.shade900,
            cardColor: Colors.grey.shade600,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.grey.shade500,
            ),
            listTileTheme: ListTileThemeData(
              tileColor: Colors.grey.shade700,
            ),
          ),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web URL navigation and deep linking.
          initialRoute: '/login', // Set the initial route to login
          onGenerateRoute: (RouteSettings routeSettings) {
            switch (routeSettings.name) {
              case SettingsView.routeName:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) =>
                      SettingsView(controller: settingsController),
                );
              case IndivPageView.routeName:
                // Extract arguments for IndivPageView
                final args = routeSettings.arguments as Map<String, String>;
                final String pageId = args['pageId']!;
                final String journalId = args['journalId']!;
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => IndivPageView(
                    pageId: pageId,
                    journalId: journalId,
                  ),
                );
              case '/login':
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const LoginPage(),
                );
              case LandingPage.routeName:
              default:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const LandingPage(),
                );
            }
          },
          routes: {
            SettingsView.routeName: (context) =>
                SettingsView(controller: settingsController),
            AccountSettingsView.routeName: (context) =>
                const AccountSettingsView(),
          },
        );
      },
    );
  }
}
