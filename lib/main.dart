import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  // For play billing library 2.0 on Android, it is mandatory to call
  // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
  // as part of initializing the app.
  InAppPurchaseConnection.enablePendingPurchases();
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
