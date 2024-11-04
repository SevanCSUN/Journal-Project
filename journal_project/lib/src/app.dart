import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/page_view.dart';
import 'sample_feature/landing_page.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(

          //the below 3 lines are needed for device preview. remove them when ready to push


          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
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
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey.shade900,
            cardColor: Colors.grey.shade800,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade800,
            ),
            listTileTheme: ListTileThemeData(
              tileColor: Colors.grey.shade700,
            ),
          ),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web URL navigation and deep linking.
        onGenerateRoute: (RouteSettings routeSettings) {
          switch (routeSettings.name) {
            case SettingsView.routeName:
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => SettingsView(controller: settingsController),
              );
            case SampleItemDetailsView.routeName:
              // Extract arguments and cast them to the expected type
              final String pageTitle = routeSettings.arguments as String; // Get the pageTitle from arguments
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => SampleItemDetailsView(pageTitle: pageTitle),
              );
            case SampleItemListView.routeName:
            default:
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const SampleItemListView(),
              );
          }
        },
        );
      },
    );
  }
}
