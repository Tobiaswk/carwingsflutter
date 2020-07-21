import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
        return ThemeData(primarySwatch: Colors.blue, buttonColor: Colors.white);
      case ThemeColor.green:
        return ThemeData(
            primarySwatch: Colors.green, buttonColor: Colors.white);
      case ThemeColor.red:
        return ThemeData(primarySwatch: Colors.red, buttonColor: Colors.white);
      case ThemeColor.purple:
        return ThemeData(
            primarySwatch: Colors.purple, buttonColor: Colors.white);
      case ThemeColor.dark:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
        );
    }
    return ThemeData(primarySwatch: Colors.blue, buttonColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
