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
          // Device Preview (for testing purposes)
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,

          restorationScopeId: 'app',

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Theme settings
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
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

          initialRoute: '/login',

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
                final String pageTitle = args['pageTitle']!;
                final String journalId = args['journalId']!;
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => IndivPageView(
                    pageTitle: pageTitle,
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
