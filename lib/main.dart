import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {

  var preferencesManager = new PreferencesManager();

  CarwingsSession _session = new CarwingsSession();

  MyAppState() {
    preferencesManager.getTheme().then((themeColor){
      configurationUpdater(_configuration.copyWith(theme: ThemeColor.values[themeColor]));
    });
  }

  Setting _configuration = new Setting(
    theme: ThemeColor.standard,
  );

  void configurationUpdater(Setting value) {
    setState(() {
      _configuration = value;
    });
  }

  ThemeData get theme {
    switch(_configuration.theme) {
      case ThemeColor.standard:
        return new ThemeData(
          primarySwatch: Colors.blue,
        );
      case ThemeColor.green:
        return new ThemeData(
          primarySwatch: Colors.green,
        );
      case ThemeColor.red:
        return new ThemeData(
          primarySwatch: Colors.red,
        );
      case ThemeColor.purple:
        return new ThemeData(
          primarySwatch: Colors.purple,
        );
      case ThemeColor.dark:
        return new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
        );
    }
    return new ThemeData(
      primarySwatch: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Carwings',
      theme: theme,
      home: new LoginPage(_session,),
      routes: <String, WidgetBuilder>{
        '/preferences': (BuildContext context) => new PreferencesPage(_configuration, configurationUpdater, _session)
      },
    );
  }
}
