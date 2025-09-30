import 'package:carwingsflutter/background_service.dart';
import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(backgroundServiceCallback);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var preferencesManager = PreferencesManager;

  Session _session = Session();

  MyAppState() {
    PreferencesManager.getTheme().then((themeColor) {
      configurationUpdater(
        _configuration.copyWith(theme: ThemeColor.values[themeColor]),
      );
    });
  }

  Setting _configuration = Setting(theme: ThemeColor.standard);

  void configurationUpdater(Setting value) {
    setState(() {
      _configuration = value;
    });
  }

  ThemeData get theme {
    switch (_configuration.theme) {
      case ThemeColor.standard:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
      case ThemeColor.green:
        return ThemeData(colorSchemeSeed: Colors.green);
      case ThemeColor.red:
        return ThemeData(colorSchemeSeed: Colors.red);
      case ThemeColor.purple:
        return ThemeData(colorSchemeSeed: Colors.purple);
      case ThemeColor.dark:
        return ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.withValues(alpha: .21),
          ),
          //scaffoldBackgroundColor: Colors.transparent,
          colorSchemeSeed: Colors.grey,
          cardColor: Colors.grey.withValues(alpha: .2),
          //dialogBackgroundColor: Color(0xFF282828),
          //drawerTheme: DrawerThemeData(backgroundColor: Colors.black),
          brightness: Brightness.dark,
        );
      case ThemeColor.amoledDark:
        return ThemeData(
          appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
          scaffoldBackgroundColor: Colors.transparent,
          primaryColor: Colors.black,
          cardColor: Colors.black,
          dialogBackgroundColor: Color(0xFF282828),
          drawerTheme: DrawerThemeData(backgroundColor: Colors.black),
          brightness: Brightness.dark,
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
          data: data.copyWith(textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
      title: 'My Leaf',
      theme: theme,
      home: LoginPage(_session),
      routes: <String, WidgetBuilder>{
        '/preferences': (BuildContext context) =>
            PreferencesPage(_configuration, configurationUpdater, _session),
      },
    );
  }
}
