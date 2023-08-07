import 'dart:io';

import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

/// Used for "keep vehicle alive" functionality
///
/// Some users have issues with their vehicles going to "deep sleep"
/// causing their vehicle to not be reachable through the API/app.
/// This functionality is reserved for European vehicles produced after
/// May 2019.
///
/// This is the callback that gets called at intervals in the background; also
/// when the app is not active either in background, foreground or not at all.
/// See the [KeepAliveVehicleHelper].
///
/// This method must be a top level function to be accessible as a
/// Flutter entry point.
@pragma('vm:entry-point')
void keepAliveVehicleTaskCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String username = inputData!['username'];
    String password = inputData['password'];
    bool isWorld = inputData['isWorld'];

    if (isWorld) {
      NissanConnectSession nissanConnect = NissanConnectSession();

      try {
        var vehicle =
            await nissanConnect.login(username: username, password: password);

        for (vehicle in nissanConnect.vehicles)
          await vehicle.requestBatteryStatusRefresh();
      } catch (e) {
        return Future.value(false);
      }

      return Future.value(true);
    }

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    Workmanager().initialize(keepAliveVehicleTaskCallbackDispatcher);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var preferencesManager = PreferencesManager();

  Session _session = Session();

  MyAppState() {
    preferencesManager.getTheme().then((themeColor) {
      configurationUpdater(
          _configuration.copyWith(theme: ThemeColor.values[themeColor]));
    });
  }

  Setting _configuration = Setting(
    theme: ThemeColor.standard,
  );

  void configurationUpdater(Setting value) {
    setState(() {
      _configuration = value;
    });
  }

  ThemeData get theme {
    switch (_configuration.theme) {
      case ThemeColor.standard:
        return ThemeData(primarySwatch: Colors.blue);
      case ThemeColor.green:
        return ThemeData(primarySwatch: Colors.green);
      case ThemeColor.red:
        return ThemeData(primarySwatch: Colors.red);
      case ThemeColor.purple:
        return ThemeData(primarySwatch: Colors.purple);
      case ThemeColor.dark:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
        );
      case ThemeColor.amoledDark:
        return ThemeData(
          appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
          scaffoldBackgroundColor: Colors.transparent,
          primaryColor: Colors.black,
          cardColor: Color(0xFF282828),
          dialogBackgroundColor: Color(0xFF282828),
          drawerTheme: DrawerThemeData(backgroundColor: Colors.black),
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enforce text scale factor; ignore system font size
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1),
          child: child!,
        );
      },
      title: 'My Leaf',
      theme: theme,
      home: LoginPage(
        _session,
      ),
      routes: <String, WidgetBuilder>{
        '/preferences': (BuildContext context) =>
            PreferencesPage(_configuration, configurationUpdater, _session)
      },
    );
  }
}
